# Android ASR native dependencies

The Android `arm64-v8a` speech runtime is built from these pinned sources:

- FunASR: `231ec5dda739c83f35e59e875736cde3ef1af161` (MIT)
- ONNX Runtime: `2e2543fbe9fae542f921d47a72d21d5a4ef0b710`, the `v1.29.0` source revision (MIT)
- nlohmann/json: `v3.11.3` (MIT)
- RE2 and the other ONNX Runtime build dependencies are pinned transitively by
  the ONNX Runtime revision.
- Paraformer quantized ONNX model: the SHA-256 value is recorded in
  `apps/mobile_app/assets/speech/manifest.json`.
- FSMN VAD quantized ONNX model: the SHA-256 value is recorded in the same
  manifest.

Run `uv run python scripts/prepare_funasr.py --build-native` to build the
runtime. The script uses Python, CMake, Ninja, Git and the Android NDK directly;
it does not invoke platform-specific project scripts.
