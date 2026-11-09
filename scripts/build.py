"""Build mobile and desktop artifacts with one cross-platform CLI."""

from __future__ import annotations

import argparse
import os
import shutil
import sys

from generate_proto import main as generate_proto
from project_tools import ROOT, environment_with_pub_cache_bin, executable, run


def clear_android_kotlin_incremental_caches() -> None:
    """Remove only stale Kotlin IC state; retain native and Flutter outputs."""
    build_root = ROOT / "apps" / "mobile_app" / "build"
    caches = [path for path in build_root.rglob("caches-jvm") if path.is_dir()]
    for cache in caches:
        shutil.rmtree(cache)
    if caches:
        print(f"Removed {len(caches)} stale Kotlin incremental cache(s)")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "target",
        choices=("android", "ios", "windows", "macos", "linux", "all"),
        help="Application target to build.",
    )
    parser.add_argument(
        "--mode",
        choices=("debug", "profile", "release"),
        default="release",
    )
    parser.add_argument(
        "--android-format",
        choices=("apk", "appbundle"),
        default="apk",
    )
    parser.add_argument(
        "--ios-codesign",
        action="store_true",
        help="Allow Xcode to sign the iOS app; the default build is unsigned.",
    )
    parser.add_argument(
        "--skip-pub-get",
        action="store_true",
        help="Use the existing Dart package resolution.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Show verbose Flutter/Gradle progress.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    desktop_target = {"darwin": "macos", "win32": "windows"}.get(sys.platform, "linux")
    if args.target == "windows" and sys.platform != "win32":
        raise SystemExit("The Windows Flutter target must be built on Windows.")
    if args.target == "macos" and sys.platform != "darwin":
        raise SystemExit("The macOS Flutter target must be built on macOS.")
    if args.target == "ios" and sys.platform != "darwin":
        raise SystemExit("The iOS Flutter target must be built on macOS.")
    if args.target == "linux" and not sys.platform.startswith("linux"):
        raise SystemExit("The Linux Flutter target must be built on Linux.")
    if args.target == "all" and sys.platform not in ("darwin", "win32", "linux"):
        raise SystemExit("The all target requires Windows, macOS or Linux.")
    flutter = executable("flutter")
    executable("protoc")
    os.environ.update(environment_with_pub_cache_bin())

    if not args.skip_pub_get:
        run([flutter, "pub", "get"])
    generate_proto()

    if args.target in ("android", "all"):
        clear_android_kotlin_incremental_caches()
        command = [flutter]
        if args.verbose:
            command.append("--verbose")
        command.extend([
            "build",
            args.android_format,
            f"--{args.mode}",
            "--target-platform",
            "android-arm64",
        ])
        if args.skip_pub_get:
            command.append("--no-pub")
        run(
            command,
            cwd=ROOT / "apps" / "mobile_app",
        )
    if args.target == "ios" or (args.target == "all" and sys.platform == "darwin"):
        command = [flutter]
        if args.verbose:
            command.append("--verbose")
        command.extend(["build", "ios", f"--{args.mode}"])
        if not args.ios_codesign:
            command.append("--no-codesign")
        if args.skip_pub_get:
            command.append("--no-pub")
        run(command, cwd=ROOT / "apps" / "mobile_app")
    if args.target in ("windows", "macos", "linux", "all"):
        target = desktop_target if args.target == "all" else args.target
        command = [flutter]
        if args.verbose:
            command.append("--verbose")
        command.extend(["build", target, f"--{args.mode}"])
        if args.skip_pub_get:
            command.append("--no-pub")
        run(command, cwd=ROOT / "apps" / "desktop_app")


if __name__ == "__main__":
    main()

