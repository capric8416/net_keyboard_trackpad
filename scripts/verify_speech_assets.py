"""Verify downloaded speech assets and optional Android native dependencies."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEECH = ROOT / "apps" / "mobile_app" / "assets" / "speech"
ANDROID_NATIVE = (
    ROOT
    / "native"
    / "asr"
    / "vendor"
    / "android-arm64-v8a"
    / "lib"
    / "libzh_speech_deps.a"
)
ANDROID_NATIVE_MANIFEST = ANDROID_NATIVE.parents[1] / "native-dependencies.json"
EXPECTED_ANDROID_NDK = "29.0.14206865"
EXPECTED_FUNASR_REVISION = "231ec5dda739c83f35e59e875736cde3ef1af161"
EXPECTED_ONNXRUNTIME_REVISION = "2e2543fbe9fae542f921d47a72d21d5a4ef0b710"
EXPECTED_FILES = {
    "funasr-paraformer-zh/am.mvn": (
        "29b3c740a2c0cfc6b308126d31d7f265fa2be74f3bb095cd2f143ea970896ae5"
    ),
    "funasr-paraformer-zh/config.yaml": (
        "bfd424b9f61846aac63591e96fe24d66b35f4643bddcb4b9bb759db8f987ab79"
    ),
    "funasr-paraformer-zh/MODEL_CARD.md": (
        "1ab1f3225e04ba4b731c819a15d498825e52cd13aac80f5d457d4d7e37aab76f"
    ),
    "funasr-paraformer-zh/model_quant.onnx": (
        "c3a06538f867c8e3d9bb9c9e1b44b126a50d732862f6c428b1b5896ee9be65c5"
    ),
    "funasr-paraformer-zh/tokens.json": (
        "2b20c2b12572d682afff84ce1c8d560f67b8b32a4c1f21567411d141ed352127"
    ),
    "funasr-fsmn-vad/am.mvn": (
        "6820fef9687708c4fc3fab2530179c8fcea6262daa25514380056cd8f6eb1754"
    ),
    "funasr-fsmn-vad/config.yaml": (
        "f58a1d402dcf666d38dae37d192278e0fd37bc54823f0b36bd68502501a4ab09"
    ),
    "funasr-fsmn-vad/MODEL_CARD.md": (
        "59ad5ed1e004a8a2b431ad4d86715f0093dee023ff7018073d3c261f60ec0e1e"
    ),
    "funasr-fsmn-vad/model_quant.onnx": (
        "9b28837838fce9685503c63139fadbad35d6c8ed485485dafdbb32e725969660"
    ),
}


def sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--require-android-native",
        action="store_true",
        help="Also require the Android arm64 native archive and manifest flag.",
    )
    args = parser.parse_args()

    manifest_path = SPEECH / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    files = manifest.get("files")
    if files != EXPECTED_FILES:
        raise RuntimeError("Speech model manifest does not match pinned file hashes")
    if manifest.get("funasr_commit") != EXPECTED_FUNASR_REVISION:
        raise RuntimeError("Speech model manifest has an unexpected FunASR revision")
    if manifest.get("onnxruntime_commit") != EXPECTED_ONNXRUNTIME_REVISION:
        raise RuntimeError(
            "Speech model manifest has an unexpected ONNX Runtime revision"
        )
    for relative, expected in EXPECTED_FILES.items():
        path = SPEECH / relative
        if not path.is_file():
            raise FileNotFoundError(f"Missing speech asset: {path}")
        actual = sha256(path)
        if actual != expected:
            raise RuntimeError(
                f"Speech asset hash mismatch for {relative}: {actual}, expected {expected}"
            )

    if args.require_android_native:
        if manifest.get("native_android_ready") is not True:
            raise RuntimeError("Speech manifest does not mark Android native as ready")
        if not ANDROID_NATIVE.is_file() or ANDROID_NATIVE.stat().st_size == 0:
            raise FileNotFoundError(f"Missing Android native archive: {ANDROID_NATIVE}")
        native_manifest = json.loads(
            ANDROID_NATIVE_MANIFEST.read_text(encoding="utf-8")
        )
        expected_native_values = {
            "target": "android-arm64-v8a",
            "funasr_revision": EXPECTED_FUNASR_REVISION,
            "onnxruntime_revision": EXPECTED_ONNXRUNTIME_REVISION,
            "ndk": EXPECTED_ANDROID_NDK,
            "archive": (
                "native/asr/vendor/android-arm64-v8a/lib/libzh_speech_deps.a"
            ),
            "archive_bytes": ANDROID_NATIVE.stat().st_size,
        }
        if native_manifest != expected_native_values:
            raise RuntimeError("Android native dependency manifest is inconsistent")

    print(f"Verified {len(EXPECTED_FILES)} pinned speech model files")
    if args.require_android_native:
        print(f"Verified Android native dependency: {ANDROID_NATIVE.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
