# 网络键鼠控制端

当前支持 Android 与 iOS。通用使用说明、配对流程、构建方式及平台支持计划见仓库 [README](../../README.md)。

控制端负责受控端列表、TLS 指纹固定、配对、连接管理、键盘、触控板和本地语音识别。Android 使用 FunASR FFI，iOS 使用强制设备端识别的 Speech framework；两者都只在用户确认结果后发送文本。共享协议与领域模型分别位于 `packages/remote_input_protocol` 和 `packages/remote_input_core`。

从仓库根目录构建：

```text
uv run python scripts/build.py android --mode release --android-format apk
uv run python scripts/build.py ios --mode release
```
