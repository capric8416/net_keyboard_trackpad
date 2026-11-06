"""Build pinned FunASR and ONNX Runtime libraries for Android arm64-v8a.

This script is intentionally Python-only. It invokes ONNX Runtime's Python
build entry point and CMake directly; it never calls build.sh, gradlew, or a
platform-specific wrapper script.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / ".native-build" / "android-arm64-v8a"
VENDOR = ROOT / "native" / "asr" / "vendor" / "android-arm64-v8a"
ORT_REVISION = "2e2543fbe9fae542f921d47a72d21d5a4ef0b710"
FUNASR_REVISION = "231ec5dda739c83f35e59e875736cde3ef1af161"
JSON_REVISION = "v3.11.3"


def run(command: list[object], *, cwd: Path | None = None) -> None:
    rendered = [str(part) for part in command]
    print("+ " + " ".join(rendered), flush=True)
    subprocess.run(rendered, cwd=cwd, check=True)


def replace(path: Path, old: str, new: str, *, required: bool = True) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        if required:
            raise RuntimeError(f"Patch context not found in {path}: {old!r}")
        return
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def checkout(name: str, url: str, revision: str) -> Path:
    target = BUILD / "sources" / name
    if not (target / ".git").exists():
        target.parent.mkdir(parents=True, exist_ok=True)
        run(["git", "init", "-q", target])
        run(["git", "-C", target, "remote", "add", "origin", url])
    result = subprocess.run(
        ["git", "-C", target, "rev-parse", "--verify", f"{revision}^{{commit}}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    reference = revision
    if result.returncode != 0:
        run(["git", "-C", target, "fetch", "--depth", "1", "origin", revision])
        reference = "FETCH_HEAD"
    run(["git", "-C", target, "checkout", "-q", "--detach", reference])
    run(["git", "-C", target, "submodule", "update", "--init", "--recursive"])
    return target


def require_revision(source: Path, revision: str) -> None:
    result = subprocess.run(
        ["git", "-C", source, "rev-parse", "HEAD"],
        text=True,
        capture_output=True,
        check=True,
    )
    actual = result.stdout.strip().lower()
    if len(revision) == 40 and actual != revision.lower():
        raise RuntimeError(
            f"Unexpected source revision at {source}: {actual}, expected {revision}"
        )


def source_roots(reference: Path | None) -> tuple[Path, Path, Path]:
    if reference is not None:
        cached = reference / "app" / "native" / "speech" / ".build-deps" / "sources"
        ort = cached / "onnxruntime-v1.29.0"
        funasr = cached / f"funasr-{FUNASR_REVISION}"
        json_source = cached / "nlohmann-json-3.11.3"
        if all(path.is_dir() for path in (ort, funasr, json_source)):
            require_revision(ort, ORT_REVISION)
            require_revision(funasr, FUNASR_REVISION)
            return ort, funasr, json_source
    return (
        checkout("onnxruntime-v1.29.0", "https://github.com/microsoft/onnxruntime.git", ORT_REVISION),
        checkout(f"funasr-{FUNASR_REVISION}", "https://github.com/modelscope/FunASR.git", FUNASR_REVISION),
        checkout("nlohmann-json-3.11.3", "https://github.com/nlohmann/json.git", JSON_REVISION),
    )


def discover_android() -> tuple[Path, Path]:
    sdk_value = os.environ.get("ANDROID_SDK_ROOT") or os.environ.get("ANDROID_HOME")
    if not sdk_value:
        local = ROOT / "apps" / "mobile_app" / "android" / "local.properties"
        for line in local.read_text(encoding="utf-8").splitlines():
            if line.startswith("sdk.dir="):
                sdk_value = line.partition("=")[2].replace("\\\\", "\\")
                break
    if not sdk_value:
        raise RuntimeError("Android SDK not found; set ANDROID_SDK_ROOT")
    sdk = Path(sdk_value).resolve()
    ndk_value = os.environ.get("ANDROID_NDK_HOME")
    if ndk_value:
        ndk = Path(ndk_value).resolve()
    else:
        candidates = sorted(
            (path for path in (sdk / "ndk").glob("*") if (path / "build/cmake/android.toolchain.cmake").is_file()),
            key=lambda path: tuple(int(part) for part in path.name.split(".") if part.isdigit()),
        )
        if not candidates:
            raise RuntimeError(f"Android NDK not found below {sdk / 'ndk'}")
        ndk = candidates[-1]
    return sdk, ndk


def stage_ort_headers(source: Path, vendor: Path) -> None:
    include = vendor / "include"
    namespaced = include / "onnxruntime"
    namespaced.mkdir(parents=True, exist_ok=True)
    session = source / "include" / "onnxruntime" / "core" / "session"
    for header in session.glob("*.h"):
        shutil.copy2(header, include / header.name)
        shutil.copy2(header, namespaced / header.name)


def build_onnxruntime(source: Path, sdk: Path, ndk: Path) -> tuple[Path, list[Path]]:
    build_dir = BUILD / "onnxruntime"
    release = build_dir / "Release"
    marker = BUILD / "onnxruntime.done"
    config_stamp = BUILD / "onnxruntime.config.json"
    archives = _runtime_archives(release)
    expected_marker = {
        "onnxruntime_revision": ORT_REVISION,
        "ndk": ndk.name,
        "abi": "arm64-v8a",
        "api": 24,
        "thread_detection": "android-libc",
    }
    if marker.is_file() and archives:
        try:
            if json.loads(marker.read_text(encoding="utf-8")) == expected_marker:
                return release, archives
        except (json.JSONDecodeError, OSError):
            pass
    if build_dir.exists() and config_stamp.is_file():
        try:
            if json.loads(config_stamp.read_text(encoding="utf-8")) != expected_marker:
                shutil.rmtree(build_dir)
        except (json.JSONDecodeError, OSError):
            shutil.rmtree(build_dir)
    config_stamp.write_text(
        json.dumps(expected_marker, indent=2) + "\n", encoding="utf-8"
    )
    command: list[object] = [
        sys.executable,
        source / "tools" / "ci_build" / "build.py",
        "--config", "Release",
        "--build_dir", build_dir,
        "--skip_tests",
        "--skip_submodule_sync",
        "--parallel", "2",
        "--android",
        "--android_sdk_path", sdk,
        "--android_ndk_path", ndk,
        "--android_abi", "arm64-v8a",
        "--android_api", "24",
        "--cmake_generator", "Ninja",
        "--cmake_extra_defines",
        "onnxruntime_BUILD_UNIT_TESTS=OFF",
        "onnxruntime_BUILD_BENCHMARKS=OFF",
        "onnxruntime_USE_TELEMETRY=OFF",
        "CMAKE_POSITION_INDEPENDENT_CODE=ON",
        # Android exposes pthread symbols from libc. Explicitly seed this
        # result so cross-compilation never probes the nonexistent
        # libpthreads (the first fallback tried by CMake's FindThreads).
        "CMAKE_HAVE_LIBC_PTHREAD=1",
        "THREADS_PREFER_PTHREAD_FLAG=ON",
    ]
    run(command, cwd=source)
    archives = _runtime_archives(release)
    if not archives:
        raise RuntimeError(f"ONNX Runtime produced no static archives under {release}")
    marker.write_text(json.dumps(expected_marker, indent=2) + "\n", encoding="utf-8")
    return release, archives


def _runtime_archives(release: Path) -> list[Path]:
    """Return ORT and every static transitive dependency needed at final link."""
    return sorted(
        path
        for path in release.rglob("*.a")
        if "test" not in path.name.lower()
        and "benchmark" not in path.name.lower()
        and "fuzz" not in path.name.lower()
    )


def build_re2(ort_release: Path) -> Path:
    candidates = sorted(
        path for path in ort_release.rglob("libre2.a")
        if "re2-build" in path.as_posix()
    )
    if candidates:
        return candidates[0]
    run(["cmake", "--build", ort_release, "--target", "re2", "--parallel", "2"])
    candidates = sorted(
        path for path in ort_release.rglob("libre2.a")
        if "re2-build" in path.as_posix()
    )
    if not candidates:
        raise RuntimeError("ONNX Runtime RE2 target did not produce libre2.a")
    return candidates[0]


def prepare_funasr(source: Path, json_source: Path) -> Path:
    work = BUILD / "funasr-source"
    if work.exists():
        shutil.rmtree(work)
    shutil.copytree(source / "runtime" / "onnxruntime", work)
    replace(work / "src" / "CMakeLists.txt", "add_library(funasr SHARED", "add_library(funasr STATIC")
    replace(
        work / "src" / "CMakeLists.txt",
        "target_compile_definitions(funasr PUBLIC -D_FUNASR_API_EXPORT -DNOMINMAX -DYAML_CPP_DLL)",
        "target_compile_definitions(funasr PUBLIC -D_FUNASR_API_EXPORT -DNOMINMAX)",
    )
    header = work / "include" / "funasrruntime.h"
    text = header.read_text(encoding="utf-8")
    if not text.startswith("#pragma once"):
        header.write_text("#pragma once\n" + text, encoding="utf-8")
    json_target = work / "third_party" / "json" / "include" / "nlohmann" / "json.hpp"
    json_target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(json_source / "single_include" / "nlohmann" / "json.hpp", json_target)
    replace(work / "src" / "tensor.h", "aligned_free(buff)", "AlignedFree(buff)", required=False)
    replace(
        work / "include" / "offline-stream.h",
        '#if !defined(__APPLE__)\n#include "itn-model.h"\n#include "com-define.h"\n#endif',
        '#if !defined(__APPLE__)\n#include "itn-model.h"\n#endif\n#include "com-define.h"',
        required=False,
    )
    string_util = work / "third_party" / "jieba" / "include" / "limonp" / "StringUtil.hpp"
    replace(string_util, "std::not1(std::ptr_fun<unsigned, bool>(IsSpace))", "[](unsigned c) { return !IsSpace(c); }", required=False)
    replace(string_util, "std::not1(std::bind2nd(std::equal_to<char>(), x))", "[x](char c) { return c != x; }", required=False)
    replace(
        string_util,
        "std::find_if(s.rbegin(), s.rend(), std::not1(std::ptr_fun<unsigned, bool>(IsSpace)))",
        "std::find_if(s.rbegin(), s.rend(), [](unsigned c) { return !IsSpace(c); })",
        required=False,
    )
    replace(
        string_util,
        "std::find_if(s.rbegin(), s.rend(), std::not1(std::bind2nd(std::equal_to<char>(), x)))",
        "std::find_if(s.rbegin(), s.rend(), [x](char c) { return c != x; })",
        required=False,
    )
    replace(
        work / "third_party" / "openfst" / "src" / "include" / "fst" / "fst.h",
        "isymbols_ = impl.isymbols_ ? impl.isymbols_->Copy() : nullptr;",
        "isymbols_.reset(impl.isymbols_ ? impl.isymbols_->Copy() : nullptr);",
        required=False,
    )
    replace(
        work / "third_party" / "openfst" / "src" / "include" / "fst" / "fst.h",
        "osymbols_ = impl.osymbols_ ? impl.osymbols_->Copy() : nullptr;",
        "osymbols_.reset(impl.osymbols_ ? impl.osymbols_->Copy() : nullptr);",
        required=False,
    )
    replace(
        work / "third_party" / "openfst" / "src" / "include" / "fst" / "bi-table.h",
        "new S(table.s_)", "new S(*table.selector_)", required=False,
    )
    replace(
        work / "third_party" / "kaldi-native-fbank" / "kaldi-native-fbank" / "csrc" / "rfft.h",
        "#include <memory>", "#include <cstdint>\n#include <memory>", required=False,
    )
    replace(work / "src" / "util.h", "#define UTIL_H", "#define UTIL_H\n#include <cstdint>", required=False)
    converter = work / "src" / "encode_converter.h"
    converter_text = converter.read_text(encoding="utf-8")
    if "template <> struct char_traits<unsigned char>" not in converter_text:
        traits = r'''namespace std {
template <> struct char_traits<unsigned char> : char_traits<char> {
  using char_type = unsigned char; using int_type = int;
  using off_type = streamoff; using pos_type = streampos; using state_type = mbstate_t;
  static void assign(char_type& r, const char_type& a) { r = a; }
  static char_type* copy(char_type* d, const char_type* s, size_t n) { for(size_t i=0;i<n;++i)d[i]=s[i]; return d; }
  static char_type* move(char_type* d, const char_type* s, size_t n) { return copy(d,s,n); }
  static bool eq(char_type a, char_type b) { return a == b; }
  static bool lt(char_type a, char_type b) { return a < b; }
  static int compare(const char_type* a, const char_type* b, size_t n) { while (n-- && *a == *b) ++a, ++b; return n == size_t(-1) ? 0 : (*a < *b ? -1 : 1); }
  static size_t length(const char_type* s) { size_t n=0; while (*s++) ++n; return n; }
  static const char_type* find(const char_type* s, size_t n, const char_type& c) { while (n--) { if (*s == c) return s; ++s; } return nullptr; }
  static int_type to_int_type(char_type c) { return c; } static char_type to_char_type(int_type c) { return static_cast<char_type>(c); }
  static bool eq_int_type(int_type a, int_type b) { return a == b; } static int_type eof() { return -1; } static int_type not_eof(int_type c) { return c == eof() ? 0 : c; }
};
template <> struct char_traits<unsigned short> : char_traits<char> {
  using char_type = unsigned short; using int_type = int; using off_type = streamoff; using pos_type = streampos; using state_type = mbstate_t;
  static void assign(char_type& r, const char_type& a) { r = a; } static char_type* copy(char_type*d,const char_type*s,size_t n){for(size_t i=0;i<n;++i)d[i]=s[i];return d;} static char_type* move(char_type*d,const char_type*s,size_t n){return copy(d,s,n);} static bool eq(char_type a,char_type b){return a==b;} static bool lt(char_type a,char_type b){return a<b;}
  static int compare(const char_type* a,const char_type* b,size_t n){while(n--&&*a==*b)++a,++b;return n==size_t(-1)?0:(*a<*b?-1:1);}
  static size_t length(const char_type* s){size_t n=0;while(*s++)++n;return n;} static const char_type* find(const char_type*s,size_t n,const char_type&c){while(n--){if(*s==c)return s;++s;}return nullptr;}
  static int_type to_int_type(char_type c){return c;} static char_type to_char_type(int_type c){return static_cast<char_type>(c);} static bool eq_int_type(int_type a,int_type b){return a==b;} static int_type eof(){return -1;} static int_type not_eof(int_type c){return c==eof()?0:c;}
};
}'''
        converter_text = converter_text.replace("#include <string>", "#include <string>\n" + traits, 1)
        converter.write_text(converter_text, encoding="utf-8")
    return work


def build_funasr(work: Path, ort_archive: Path, ort_source: Path, ndk: Path) -> tuple[Path, list[Path]]:
    staging = BUILD / "ort-staging"
    if staging.exists():
        shutil.rmtree(staging)
    (staging / "lib").mkdir(parents=True)
    stage_ort_headers(ort_source, staging)
    shutil.copy2(ort_archive, staging / "lib" / "libonnxruntime.a")
    build_dir = BUILD / "funasr"
    cached_archives = sorted(
        path for path in build_dir.rglob("*.a")
        if "test" not in path.name.lower() and "benchmark" not in path.name.lower()
    )
    if any(path.name == "libfunasr.a" for path in cached_archives):
        return build_dir, cached_archives
    run([
        "cmake", "-S", work, "-B", build_dir, "-G", "Ninja",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DBUILD_SHARED_LIBS=OFF",
        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON",
        "-DCMAKE_CXX_STANDARD=17",
        "-DCMAKE_HAVE_LIBC_PTHREAD=1",
        "-DTHREADS_PREFER_PTHREAD_FLAG=ON",
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
        f"-DONNXRUNTIME_DIR={staging}",
        "-DENABLE_FFMPEG=OFF",
        "-DFUNASR_BUILD_TESTS=OFF",
        f"-DCMAKE_TOOLCHAIN_FILE={ndk / 'build/cmake/android.toolchain.cmake'}",
        "-DANDROID_ABI=arm64-v8a",
        "-DANDROID_PLATFORM=android-24",
    ])
    run(["cmake", "--build", build_dir, "--target", "funasr", "--parallel", "2"])
    archives = sorted(
        path for path in build_dir.rglob("*.a")
        if "test" not in path.name.lower() and "benchmark" not in path.name.lower()
    )
    if not any(path.name == "libfunasr.a" for path in archives):
        raise RuntimeError("FunASR build did not produce libfunasr.a")
    return build_dir, archives


def ndk_tool(ndk: Path, name: str) -> Path:
    prebuilt = next((ndk / "toolchains" / "llvm" / "prebuilt").glob("*"))
    tool = prebuilt / "bin" / f"{name}.exe"
    if not tool.is_file():
        tool = prebuilt / "bin" / name
    if not tool.is_file():
        raise RuntimeError(f"Android NDK tool not found: {name}")
    return tool


def combine_archives(ndk: Path, archives: list[Path], output: Path) -> None:
    archiver = ndk_tool(ndk, "llvm-ar")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.unlink(missing_ok=True)
    script = "create " + str(output) + "\n"
    script += "\n".join(f"addlib {path}" for path in archives)
    script += "\nsave\nend\n"
    print(f"+ {archiver} -M", flush=True)
    subprocess.run([str(archiver), "-M"], input=script, text=True, check=True)


def validate_archive(ndk: Path, archive: Path) -> None:
    result = subprocess.run(
        [str(ndk_tool(ndk, "llvm-nm")), "--defined-only", "-gC", str(archive)],
        text=True,
        capture_output=True,
        check=True,
    )
    required = ("FunOfflineInit", "FsmnVadInit", "OrtGetApiBase")
    missing = [symbol for symbol in required if symbol not in result.stdout]
    if missing:
        raise RuntimeError(
            f"Combined speech archive is missing symbols: {', '.join(missing)}"
        )


def validate_link(ndk: Path, archive: Path, include: Path) -> None:
    """Link the real JNI bridge so missing transitive archives fail early."""
    prebuilt = next((ndk / "toolchains" / "llvm" / "prebuilt").glob("*"))
    output = BUILD / "libnet_keyboard_asr.linkcheck.so"
    run([
        ndk_tool(ndk, "clang++"),
        "--target=aarch64-none-linux-android24",
        f"--sysroot={prebuilt / 'sysroot'}",
        "-std=c++17",
        "-O2",
        "-fPIC",
        "-shared",
        "-static-libstdc++",
        "-Wl,--no-undefined",
        "-Wl,--gc-sections",
        "-DNET_KEYBOARD_HAS_FUNASR=1",
        f"-I{include}",
        ROOT / "native" / "asr" / "asr_bridge.cpp",
        archive,
        "-llog",
        "-landroid",
        "-latomic",
        "-lm",
        "-lz",
        "-ldl",
        "-o",
        output,
    ])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--reference",
        type=Path,
        default=Path(os.environ.get("ZH_TEXTBOOK_ROOT", r"D:\sources\zh-lang-textbook")),
        help="Optional source cache; never modified",
    )
    args = parser.parse_args()
    sdk, ndk = discover_android()
    ort_source, funasr_source, json_source = source_roots(args.reference.resolve())
    ort_release, ort_archives = build_onnxruntime(ort_source, sdk, ndk)
    re2 = build_re2(ort_release)

    # ONNX embeds generated protobuf objects in libonnx.a as well as
    # libonnx_proto.a. Keep the former to avoid duplicate definitions.
    if any(path.name == "libonnx.a" for path in ort_archives):
        ort_archives = [path for path in ort_archives if path.name != "libonnx_proto.a"]
    ort_main = next(
        (path for path in ort_archives if path.name == "libonnxruntime_common.a"),
        ort_archives[0],
    )
    work = prepare_funasr(funasr_source, json_source)
    _, funasr_archives = build_funasr(work, ort_main, ort_source, ndk)
    inputs = ort_archives + [re2] + funasr_archives
    unique: list[Path] = []
    seen: set[Path] = set()
    for path in inputs:
        resolved = path.resolve()
        if resolved not in seen:
            seen.add(resolved)
            unique.append(resolved)
    output = VENDOR / "lib" / "libzh_speech_deps.a"
    combine_archives(ndk, unique, output)
    validate_archive(ndk, output)
    include = VENDOR / "include"
    include.mkdir(parents=True, exist_ok=True)
    shutil.copy2(work / "include" / "funasrruntime.h", include / "funasrruntime.h")
    stage_ort_headers(ort_source, VENDOR)
    validate_link(ndk, output, include)
    manifest = {
        "target": "android-arm64-v8a",
        "funasr_revision": FUNASR_REVISION,
        "onnxruntime_revision": ORT_REVISION,
        "ndk": ndk.name,
        "archive": str(output.relative_to(ROOT)).replace("\\", "/"),
        "archive_bytes": output.stat().st_size,
    }
    (VENDOR / "native-dependencies.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )
    print(f"FunASR Android vendor ready: {output} ({output.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
