# /// script
# requires-python = ">=3.12"
# dependencies = ["pillow>=11.0.0"]
# ///

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[1]
ANDROID_ICON_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
WINDOWS_ICON_SIZES = (16, 20, 24, 32, 40, 48, 64, 128, 256)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate Android and Windows application icons.",
    )
    parser.add_argument(
        "--source",
        type=Path,
        default=PROJECT_ROOT / "icon.png",
        help="Square PNG source image (default: icon.png in the project root).",
    )
    return parser.parse_args()


def load_source(path: Path) -> Image.Image:
    with Image.open(path) as image:
        source = image.convert("RGBA")
    if source.width != source.height:
        raise ValueError(f"Icon source must be square, got {source.size}")
    return source


def generate_android_icons(source: Image.Image) -> None:
    resource_root = (
        PROJECT_ROOT / "apps" / "mobile_app" / "android" / "app" / "src" / "main" / "res"
    )
    for directory, size in ANDROID_ICON_SIZES.items():
        output = resource_root / directory / "ic_launcher.png"
        output.parent.mkdir(parents=True, exist_ok=True)
        source.resize((size, size), Image.Resampling.LANCZOS).save(
            output,
            format="PNG",
            optimize=True,
        )
        print(f"Android {size}x{size}: {output.relative_to(PROJECT_ROOT)}")


def generate_windows_icon(source: Image.Image) -> None:
    output = (
        PROJECT_ROOT
        / "apps"
        / "desktop_app"
        / "windows"
        / "runner"
        / "resources"
        / "app_icon.ico"
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    source.save(output, format="ICO", sizes=[(size, size) for size in WINDOWS_ICON_SIZES])
    print(
        "Windows "
        f"{', '.join(f'{size}x{size}' for size in WINDOWS_ICON_SIZES)}: "
        f"{output.relative_to(PROJECT_ROOT)}"
    )


def main() -> None:
    args = parse_args()
    source_path = args.source.resolve()
    source = load_source(source_path)
    print(f"Source {source.width}x{source.height}: {source_path}")
    generate_android_icons(source)
    generate_windows_icon(source)


if __name__ == "__main__":
    main()
