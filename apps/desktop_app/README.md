# 网络键鼠受控端

当前支持 Windows 与 macOS，计划扩展 Linux。运行方式、配对、辅助功能权限、按键映射、构建与发布限制见仓库 [README](../../README.md)。

从仓库根目录通过统一脚本构建：

```text
uv run python scripts/build.py macos --mode release
uv run python scripts/build.py windows --mode release
```

macOS 目标只能在 macOS 构建，Windows 目标只能在 Windows 构建。`flutter run -d macos` 和 `flutter run -d windows` 仅用于本地调试运行，不作为交付构建入口。

macOS 原生桥接位于 `macos/Runner/MainFlutterWindow.swift`；共享 gRPC 服务通过 `ControlledDeviceInputInjector` 调用各平台。macOS 不启用 App Sandbox，身份和配对信息存于 Keychain。首次输入前需在系统设置授予辅助功能权限。
