"""Prepare pinned FunASR models and Android native dependencies."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]


def hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def copy_tree(source: Path, target: Path) -> None:
    if not source.is_dir():
        raise FileNotFoundError(f"Missing FunASR source directory: {source}")
    target.mkdir(parents=True, exist_ok=True)
    for item in source.rglob("*"):
        if item.is_file() and item.name != ".gitkeep":
            destination = target / item.relative_to(source)
            destination.parent.mkdir(parents=True, exist_ok=True)
            if not destination.exists() or destination.stat().st_size != item.stat().st_size:
                shutil.copy2(item, destination)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--reference",
        type=Path,
        default=Path(os.environ.get("ZH_TEXTBOOK_ROOT", r"D:\sources\zh-lang-textbook")),
        help="zh-lang-textbook repository root",
    )
    parser.add_argument(
        "--build-native",
        action="store_true",
        help="Build pinned ONNX Runtime and FunASR for Android arm64-v8a",
    )
    args = parser.parse_args()
    reference = args.reference.resolve()
    source_assets = reference / "app" / "assets" / "speech"
    target_assets = ROOT / "apps" / "mobile_app" / "assets" / "speech"
    models = ("funasr-paraformer-zh", "funasr-fsmn-vad")
    for model in models:
        copy_tree(source_assets / model, target_assets / model)

    local_vendor = ROOT / "native" / "asr" / "vendor" / "android-arm64-v8a"
    reference_vendor = reference / "app" / "native" / "speech" / "vendor" / "android-arm64-v8a"
    if reference_vendor.is_dir():
        copy_tree(reference_vendor, local_vendor)
    if args.build_native:
        subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts" / "build_funasr_android.py"),
                "--reference",
                str(reference),
            ],
            cwd=ROOT,
            check=True,
        )
    elif not (local_vendor / "lib" / "libzh_speech_deps.a").is_file():
        print(
            "Android FunASR native vendor is not ready. Run this command again "
            "with --build-native before building the APK."
        )

    manifest = {
        "funasr_commit": "231ec5dda739c83f35e59e875736cde3ef1af161",
        "files": {
            str(path.relative_to(target_assets)).replace("\\", "/"): hash_file(path)
            for model in models
            for path in sorted((target_assets / model).rglob("*"))
            if path.is_file()
        },
        "onnxruntime_commit": "2e2543fbe9fae542f921d47a72d21d5a4ef0b710",
        "native_android_ready": (local_vendor / "lib" / "libzh_speech_deps.a").is_file(),
    }
    (target_assets / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"Prepared {len(manifest['files'])} FunASR model files")
    print(f"Android native ready: {manifest['native_android_ready']}")


if __name__ == "__main__":
    main()
