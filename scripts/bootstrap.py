"""Initialize Flutter runners, dependencies, and generated protocol code."""

from __future__ import annotations

import argparse
import os

from generate_proto import main as generate_proto
from project_tools import ROOT, environment_with_pub_cache_bin, executable, run


PROTOC_PLUGIN_VERSION = "25.1.0"


def create_runners(flutter: str) -> None:
    mobile = ROOT / "apps" / "mobile_app"
    desktop = ROOT / "apps" / "desktop_app"
    if not (mobile / "android").is_dir():
        pubspec = (mobile / "pubspec.yaml").read_bytes()
        try:
            run(
                [
                    flutter,
                    "create",
                    "--platforms=android",
                    "--org=com.netkeyboard",
                    "--project-name=net_keyboard_mobile",
                    "--no-pub",
                    ".",
                ],
                cwd=mobile,
            )
        finally:
            (mobile / "pubspec.yaml").write_bytes(pubspec)
    for platform in ("windows", "macos"):
        if not (desktop / platform).is_dir():
            pubspec = (desktop / "pubspec.yaml").read_bytes()
            try:
                run(
                    [
                        flutter,
                        "create",
                        f"--platforms={platform}",
                        "--org=com.netkeyboard",
                        "--project-name=net_keyboard_desktop",
                        "--no-pub",
                        ".",
                    ],
                    cwd=desktop,
                )
            finally:
                (desktop / "pubspec.yaml").write_bytes(pubspec)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--skip-doctor",
        action="store_true",
        help="Do not run flutter doctor after initialization.",
    )
    parser.add_argument(
        "--skip-runners",
        action="store_true",
        help="Do not generate missing Android, Windows and macOS runner files.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    flutter = executable("flutter")
    dart = executable("dart")
    executable("uv")
    executable("protoc")

    run([flutter, "config", "--enable-android", "--enable-windows-desktop", "--enable-macos-desktop"])
    if not args.skip_runners:
        create_runners(flutter)

    run(
        [
            dart,
            "pub",
            "global",
            "activate",
            "protoc_plugin",
            PROTOC_PLUGIN_VERSION,
        ]
    )
    run([flutter, "pub", "get"])

    # The global Dart executable directory may not have been on PATH before the
    # activation above. Make it visible for this process before invoking protoc.
    os.environ.update(environment_with_pub_cache_bin())
    generate_proto()

    if not args.skip_doctor:
        run([flutter, "doctor", "-v"])


if __name__ == "__main__":
    main()

