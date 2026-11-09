# 网络键鼠受控端

当前支持 Windows、macOS 与 Linux（X11 / Wayland portal）。运行方式、配对、辅助功能权限、按键映射、构建与发布限制见仓库 [README](../../README.md)。

从仓库根目录通过统一脚本构建：

```text
uv run python scripts/build.py macos --mode release
uv run python scripts/build.py windows --mode release
uv run python scripts/build.py linux --mode release
```

macOS 目标只能在 macOS 构建，Windows 目标只能在 Windows 构建。`flutter run -d macos` 和 `flutter run -d windows` 仅用于本地调试运行，不作为交付构建入口。

macOS 原生桥接位于 `macos/Runner/MainFlutterWindow.swift`；共享 gRPC 服务通过 `ControlledDeviceInputInjector` 调用各平台。macOS 不启用 App Sandbox，身份和配对信息存于 Keychain。首次输入前需在系统设置授予辅助功能权限。

X11 原生桥接位于 `linux/runner/linux_input.cc`，使用 XTEST 注入键盘和鼠标；X11 Unicode 文本通过剪贴板和 Shift+Insert 粘贴（替换剪贴板）。Linux 需要 AppIndicator 托盘和已解锁的 Secret Service。Linux 目标仅能在 Linux 构建，使用 `flutter run -d linux` 调试。openSUSE Leap 依赖和验收步骤见根 README。

Wayland 后端位于 `linux/runner/wayland_input.cc`：使用 RemoteDesktop portal，需在状态页明确授权键盘和鼠标；中文/emoji 使用 Clipboard portal 与 Ctrl+V，可切换终端 Ctrl+Shift+V。取消/撤销可重试，监听不依赖输入授权，不需要 root。KDE Wayland 真机测试及 portal 日志命令见根 README。
