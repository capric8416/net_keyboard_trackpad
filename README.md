# Network Keyboard & Pointer（网络键鼠）

局域网远程输入工具，由“网络键鼠控制端”和“网络键鼠受控端”组成。控制端提供触控键盘、语音输入和触控板，并通过 gRPC 将输入发送到受控端；受控端常驻后台，将命令注入当前激活窗口。

当前控制端支持 Android 和 iOS；当前受控端支持 Windows、macOS 和 Linux（X11 / Wayland portal）。产品范围、协议、安全约束和完整任务列表见 [`plan.md`](plan.md)。平台无关流程包含 TLS gRPC、TOTP 首次配对、控制会话、64 键键盘、右侧多点触控板、本地语音识别和结果确认；输入注入与语音识别由各平台分别实现。

## 角色与平台

| 产品角色 | 当前平台 | 计划平台 | 仓库应用 |
| --- | --- | --- | --- |
| 网络键鼠控制端 | Android、iOS | 其他移动平台 | `apps/mobile_app` |
| 网络键鼠受控端 | Windows、macOS、Linux（X11 / Wayland portal） | 其他桌面后端 | `apps/desktop_app` |

通用产品说明、界面和协议展示名只使用“控制端”和“受控端”。系统名称仅用于构建步骤、平台实现及操作系统限制。

## 仓库结构

```text
apps/
├─ mobile_app/                 网络键鼠控制端 Flutter 应用
└─ desktop_app/                网络键鼠受控端 Flutter 应用
packages/
├─ remote_input_core/          平台无关的键码、64 键布局和状态模型
├─ remote_input_protocol/      Protocol Buffers/gRPC 契约
└─ desktop_input_windows/      Windows scan code 映射
scripts/                       uv 执行的跨平台 Python 工具
tool/                          工具版本与无依赖验证入口
```

仓库自动化统一使用 Python，通过 uv 运行。项目不维护 `.sh`、`.ps1`、`.bat` 或 `.cmd` 脚本。

## 开发环境

已验证的首轮工具版本记录在 [`tool/versions.md`](tool/versions.md)：

| 工具 | 版本 | 用途 |
| --- | --- | --- |
| Flutter | 3.44.0 stable | 两端 Flutter 应用 |
| Dart | 3.12.1 | Dart workspace、代码生成插件 |
| Python | 3.12.11 | 跨平台仓库工具 |
| uv | 0.13.6 | Python 环境和锁文件 |
| protoc | 31.1 | protobuf 编译器 |
| protoc_plugin | 25.1.0 | 生成 Dart protobuf/gRPC 代码 |
| Android NDK | 29.0.14206865 | FunASR/ONNX Runtime 与 Android JNI 链接 |
| CMake | 4.1.2 | Windows runner 和 Android 原生库 |

工具小版本可以更新，但 Flutter、Dart、protobuf runtime 和 protoc plugin 必须保持相互兼容。升级后应同步修改版本文档、锁文件并重新生成协议代码。

### 通用必备工具

安装并加入 `PATH`：

1. Git。
2. Flutter stable SDK；Flutter 自带对应的 Dart SDK。
3. Python 3.12。
4. uv。
5. protoc。

执行以下命令确认终端能够找到工具：

```text
git --version
flutter --version
dart --version
python --version
uv --version
protoc --version
```

### Android 构建环境

安装 Android Studio，并在 SDK Manager 中安装：

- Android SDK Platform；
- Android SDK Build-Tools；
- Android SDK Command-line Tools；
- Android SDK Platform-Tools；
- Android NDK (Side by side) 29.0.14206865；
- CMake 4.1.2。

配置 Flutter 能找到 Android SDK，然后接受 Android licenses：

```text
flutter config --android-sdk <android-sdk-directory>
flutter doctor --android-licenses
```

必须至少连接一台 arm64 Android 真机验证 FunASR。模拟器可用于普通 UI 开发，但只有在提供相应 ABI 的原生 FunASR 库后才能运行语音识别。

### iOS 构建环境

iOS 控制端只能在 macOS 上构建。安装并首次启动 Xcode，接受许可证并安装 Xcode Command Line Tools；同时安装 CocoaPods。执行 `flutter doctor -v`，确认 `Xcode - develop for iOS and macOS` 可用。未签名构建不需要 Apple Developer 账号；安装到真机或发布时，需要在 `apps/mobile_app/ios/Runner.xcworkspace` 中为 Runner 配置唯一 Bundle Identifier 和 Development Team。

### Windows 构建环境

Windows 受控端必须在 Windows 上编译。安装 Visual Studio 2022，并选择工作负载 `Desktop development with C++`，同时确保包含：

- MSVC C++ x64/x86 build tools；
- Windows 10 或 Windows 11 SDK；
- C++ CMake tools for Windows。

安装后执行：

```text
flutter doctor -v
```

`Windows toolchain` 必须显示可用，才能编译该平台的受控端。

## 首次初始化

以下命令都从仓库根目录执行。

### 1. 初始化 Python 工具环境

```text
uv sync --frozen
```

uv 会按照 `pyproject.toml` 和 `uv.lock` 创建项目虚拟环境。当前 Python 工具没有第三方运行时依赖，但仍统一通过 uv 执行，以便后续安全地增加依赖。

### 2. 初始化 Flutter、协议和依赖

```text
uv run python scripts/bootstrap.py
```

该命令会依次：

1. 检查 `flutter`、`dart`、`uv` 和 `protoc`；
2. 启用 Flutter Android、iOS、Windows、macOS 与 Linux target；
3. 为缺失的平台生成 `apps/mobile_app/android`、`apps/mobile_app/ios`、`apps/desktop_app/windows`、`apps/desktop_app/macos` 和 `apps/desktop_app/linux` runner；
4. 安装固定版本的 `protoc_plugin`；
5. 在 workspace 根目录执行 `flutter pub get`；
6. 从 `remote_input.proto` 生成 Dart protobuf/gRPC 源码；
7. 执行 `flutter doctor -v`。

生成 runner 时脚本会保留两个 app 已有的 `pubspec.yaml`。如果 runner 已存在，脚本不会重复生成。

CI 或已经确认 toolchain 正常的机器可跳过 doctor：

```text
uv run python scripts/bootstrap.py --skip-doctor
```

只安装依赖和生成协议、不创建 runner：

```text
uv run python scripts/bootstrap.py --skip-runners --skip-doctor
```

### 3. 单独重新生成 gRPC 代码

修改 [`remote_input.proto`](packages/remote_input_protocol/proto/remote_input.proto) 后执行：

```text
uv run python scripts/generate_proto.py
```

生成文件位于：

```text
packages/remote_input_protocol/lib/src/generated/
```

需要重新生成并提交以下文件：

- `remote_input.pb.dart`
- `remote_input.pbenum.dart`
- `remote_input.pbgrpc.dart`
- `remote_input.pbjson.dart`

协议字段号和枚举值发布后不得修改或复用；新增字段必须使用新编号。

## 在 Android 构建控制端

首次编译前必须先完成“首次初始化”。

### Release APK

```text
uv run python scripts/build.py android --mode release --android-format apk
```

产物：

```text
apps/mobile_app/build/app/outputs/flutter-apk/app-release.apk
```

### Release Android App Bundle

```text
uv run python scripts/build.py android --mode release --android-format appbundle
```

产物：

```text
apps/mobile_app/build/app/outputs/bundle/release/app-release.aab
```

### Debug APK

```text
uv run python scripts/build.py android --mode debug --android-format apk
```

Debug 产物位于 `apps/mobile_app/build/app/outputs/flutter-apk/`。

正式发布前需要在 `apps/mobile_app/android` 配置独立的 release keystore。密钥、密码和签名配置不得提交到仓库。

## 在 iOS 构建控制端

iOS 构建必须在 macOS 上执行。默认生成无需开发者证书的未签名应用：

```text
uv run python scripts/build.py ios --mode release
```

Release 产物位于 `apps/mobile_app/build/ios/iphoneos/Runner.app`。未签名 `.app` 用于编译验证，不能直接安装到普通真机或提交 App Store。

配置 Runner 的 Development Team、Bundle Identifier 和签名能力后，可以让构建脚本调用 Xcode 签名：

```text
uv run python scripts/build.py ios --mode release --ios-codesign
```

Debug 构建：

```text
uv run python scripts/build.py ios --mode debug
```

iOS 首次使用会请求本地网络、麦克风和语音识别权限。键盘、触控板、TLS 配对和安全存储复用控制端通用实现；语音使用 iOS 设备端中文语音识别，并禁止自动回退到云端。模拟器可验证 UI 和连接流程，权限、设备端语音和真机安装必须在 iPhone/iPad 上验收。

当前 Android FunASR 模型仍由共享 Flutter asset bundle 声明，因此也会进入 iOS 包但不会在 iOS 加载，导致安装包偏大；后续应拆分平台资源包。

## 在 Windows 构建受控端

Windows 受控端必须在装有 Visual Studio C++ toolchain 的 Windows 环境中构建：

```text
uv run python scripts/build.py windows --mode release
```

Release 目录：

```text
apps/desktop_app/build/windows/x64/runner/Release/
```

交付时必须分发整个 `Release` 目录，不能只复制 `.exe`，因为 Flutter runtime、插件 DLL 和数据目录都是运行时依赖。

Debug 构建：

```text
uv run python scripts/build.py windows --mode debug
```

Debug 目录通常位于：

```text
apps/desktop_app/build/windows/x64/runner/Debug/
```

## 在 macOS 构建受控端

在 macOS 上安装 Xcode（完成首次启动和许可证确认）、Xcode Command Line Tools 与 CocoaPods；用 `flutter doctor -v` 确认 macOS toolchain 可用。

```text
uv run python scripts/build.py macos --mode release
```

Release 产物：`apps/desktop_app/build/macos/Build/Products/Release/net_keyboard_desktop.app`。分发整个 `.app`。跨机器发布需自行配置 Developer ID 签名及公证；脚本不会提交公证或安装证书。

Debug 构建：

```text
uv run python scripts/build.py macos --mode debug
```

Debug 产物位于 `apps/desktop_app/build/macos/Build/Products/Debug/net_keyboard_desktop.app`。需要直接连接调试器运行时，使用后文“本地调试运行”中的 Flutter 命令；该命令不作为交付构建入口。

启动后受控端驻留菜单栏，点击图标打开状态页，关闭窗口继续监听；再次启动会唤醒已有实例。控制端按现有流程填写受控端的局域网地址、端口、TLS 指纹和安全码，键盘、语音确认文本与触控板复用同一协议。当前 Android 实现仍在本地完成语音识别。

首次使用在状态页点击“授权 / 重新检查”，进入 **系统设置 → 隐私与安全性 → 辅助功能**，允许受控端控制此设备；返回后点击重新检查。未授权或权限被撤销时，输入命令返回 `INPUT_BLOCKED`。授权变化可能需要重启应用；更新签名或移动应用后也可能需要重新授权。系统询问局域网访问或防火墙入站权限时，允许受信任局域网访问 TCP 39091。

macOS 使用 Core Graphics 注入事件，凭据保存在 macOS Keychain（不使用共享 Keychain 权限）。为支持跨应用输入，此 runner 不启用 App Sandbox；当前交付范围是本地 `.app`，商店发行需要另行评估。

| 控制端按键 | macOS 行为 |
| --- | --- |
| Meta | Command（左右独立） |
| Alt | Option（左右独立） |
| Ctrl、Shift | Control、Shift（左右独立） |
| Backspace / Delete | 向后删除 / 向前删除 |
| Print Screen（Fn+P） | Command+Shift+3 系统截图 |
| Menu（Fn+\） | Shift+F10，是否打开菜单由目标应用决定 |
| Home / End | 使用 macOS 原生 Home / End 语义 |

复制粘贴使用 Meta+C / Meta+V。按键字符受 Mac 当前键盘布局和输入法影响。中文与 emoji 文本使用 Unicode 事件；部分应用自行处理键盘事件，可能忽略 Unicode 内容。Core Graphics 事件提交后没有目标应用接收确认，因此 ACK 仅表示事件已提交。安全输入、锁屏、登录界面和受保护应用不保证可用。

手工验收：控制端配对 macOS 受控端，在 TextEdit、浏览器输入框与 Terminal 中检查普通键、左右修饰键、Command+C/V、中文/emoji、单击/双击/右键、双轴滚动；撤销辅助功能权限后确认命令失败，再授权恢复；关闭窗口、重复启动、断网重连和退出后端口释放也需验收。

## 在 Linux（openSUSE Leap，X11 / Wayland）构建受控端

Linux runner 使用 GTK 3；X11 通过 XTEST 注入，Wayland 通过桌面 RemoteDesktop portal 授权后注入（目标为 KDE Plasma 6 / KWin）。使用 `echo $XDG_SESSION_TYPE` 确认当前会话。即使应用界面运行在 XWayland，Wayland 会话也使用 portal，不会退回只能控制部分应用的 XTEST。

openSUSE Leap 16.1 构建依赖（需要已启用仓库提供这些包）：

```text
sudo zypper install clang cmake ninja pkg-config gtk3-devel glib2-devel libstdc++-devel libX11-devel libXtst-devel libsecret-devel libappindicator3-devel
flutter doctor -v
uv run python scripts/bootstrap.py --skip-doctor
uv run python scripts/build.py linux --mode release
```

若仓库找不到 AppIndicator 包，使用 `zypper search -s appindicator` 查找提供 `appindicator3-0.1` 或 `ayatana-appindicator3-0.1` 的开发包；当前 system_tray 插件构建需要其中一个 pkg-config 模块。凭据通过 flutter_secure_storage 保存在 Secret Service；桌面必须提供并解锁 Secret Service（如 GNOME Keyring，或启用 Secret Service 的 KWallet），缺失时身份初始化会失败，不会退回明文保存。

产物位于 `apps/desktop_app/build/linux/x64/release/bundle/`（ARM64 为 `arm64`）；分发整个 bundle。运行：

```text
apps/desktop_app/build/linux/x64/release/bundle/net_keyboard_desktop
```

本地调试在 `apps/desktop_app` 执行 `flutter run -d linux`。启动后通过托盘打开状态窗口，关闭窗口继续监听，再次运行会打开已有实例；桌面面板需支持 AppIndicator/System Tray。托盘初始化失败时保留可见窗口。需要开机启动时可在桌面“自动启动”设置中添加 bundle 中可执行文件的绝对路径。

X11 键盘支持左右 Ctrl/Alt/Shift/Super（Meta）、F1–F12、导航键、Print Screen 和 Menu；普通键按当前 X11 键盘映射解析。触控板支持相对移动、三键及双轴滚动（累计每 120 协议单位发送一格）。Unicode 文本（中文、emoji 等）写入系统剪贴板后用 Shift+Insert 粘贴，**会替换 CLIPBOARD 和 PRIMARY selection 内容**（兼容终端的 Shift+Insert）。目标应用需支持 Shift+Insert；终端可能弹出多行粘贴确认。ACK 表示事件已提交，不能确认目标应用是否消费。不要在确认语音文本与完成粘贴之间切换焦点。

### Wayland 授权和测试

Wayland 需桌面提供 `org.freedesktop.portal.RemoteDesktop`；中文/emoji 粘贴还需 `org.freedesktop.portal.Clipboard`。openSUSE KDE 的运行时包名为 `xdg-desktop-portal` 和 `xdg-desktop-portal-kde6`，可先用以下命令检查（不需要 root 输入注入服务或额外 libei 开发包）：

```text
rpm -q xdg-desktop-portal xdg-desktop-portal-kde6
systemctl --user status xdg-desktop-portal.service plasma-xdg-desktop-portal-kde.service
```

1. 退出旧受控端，注销后选择 Plasma Wayland 登录，再运行同一个 bundle；构建无需在 Wayland 会话下进行。
2. 从托盘打开状态窗口，点击 Linux 输入状态旁的“授权 / 重新检查”，在系统对话框允许键盘、鼠标及剪贴板控制。不申请录屏或麦克风。
3. 状态页显示“已授权”后，从 Android 按现有地址、39091 端口和配对流程连接；先在原生 Wayland 编辑器/浏览器中测试，再检查 XWayland 应用。
4. 测试字母、数字、F1–F12、左右 Ctrl/Alt/Shift/Super、导航键，单击/双击/右键、相对移动和双轴滚动。普通键使用 evdev 物理位置，字符由当前桌面键盘布局决定。
5. 确认语音文本后通过 Clipboard portal 粘贴中文、emoji 和多行文本。默认 Ctrl+V，向终端输入前在受控端状态页打开“语音文本粘贴到终端”（Ctrl+Shift+V）。此开关本次进程内生效。**会替换 CLIPBOARD，Wayland 不修改 PRIMARY**；目标需支持对应粘贴快捷键。目标不消费粘贴时 ACK 也可能成功；未授予 clipboard 时文本返回 INPUT_BLOCKED，键盘/鼠标仍可用。
6. 点击“停止 Wayland 控制”，或从系统远程控制指示器撤销授权，验证 Android 输入失败；重新授权后再发送新输入。取消授权可重试；授权不会跨应用重启保存，不重放失败或未授权时的命令。

网络监听和输入授权独立：未授权时仍可配对，但输入返回 INPUT_BLOCKED。桌面不支持 portal、服务中断、拒绝或撤销时，状态页给出原因；重新授权期间界面保持响应，授权请求 120 秒超时。锁屏、登录界面及其他用户会话不在支持范围。授权/键盘事件通过标准 RemoteDesktop Notify 方法发送，不建立 EIS 连接；Clipboard 内容仅在确认文本后提供，不读取或同步原有剪贴板。

如果授权失败，收集状态页错误及 portal 日志：

```text
journalctl --user -b -u xdg-desktop-portal.service -u plasma-xdg-desktop-portal-kde.service --no-pager -n 100
```

实现参考：[RemoteDesktop portal](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.RemoteDesktop.html)、[Clipboard portal](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Clipboard.html)。当前自动回归使用隔离模拟 portal；KDE Wayland 真机输入和系统授权对话框仍需手工验收。

在受信任局域网内按需放行 firewalld 的 TCP 39091（或配置端口），不要关闭整个防火墙。登录/锁屏、其他用户会话、缺少 RemoteDesktop portal 的 Wayland 桌面、受保护窗口和游戏独占输入不在支持范围。

手工验收：从 Android 配对后，在文本编辑器、浏览器输入框和终端检查普通键、左右修饰键、Ctrl+C/V、中文/emoji、单击/双击/右键及横纵滚动；检查窗口关闭、重复启动、重连、退出释放端口和重启后凭据恢复。当前仓库中的自动检查不能替代 Leap 16.1 真机端到端验收。

## 同时编译控制端和受控端

在 Windows 上安装好 Android 和 Windows 两套 toolchain 后可以执行：

```text
uv run python scripts/build.py all --mode release --android-format apk
```

`all` 在 Windows 构建 Android+Windows，在 macOS 构建 Android+iOS+macOS，在 Linux 构建 Android+Linux。使用 `all` 仍需该宿主上对应的全部 toolchain；只构建 iOS 时不需要 Android SDK。

`build.py` 默认先执行 `flutter pub get` 和 protobuf 生成，再编译目标。依赖和协议代码已经确认没有变化时可以减少重复工作：

```text
uv run python scripts/build.py all --mode release --skip-pub-get
```

`--skip-pub-get` 会同时向 Flutter 传递 `--no-pub`。Android 当前只支持 arm64，构建脚本固定传递 `--target-platform android-arm64`，避免生成不可运行的其他 ABI 产物。需要查看 Flutter 和 Gradle 的具体进度时增加 `--verbose`。

## 生成应用图标

Linux 窗口和任务栏图标由 `linux/runner/resources/app_icon.png` 通过 GResource 嵌入可执行文件，托盘使用共享的 `assets/tray_icon.png`。仅更新 Linux 图标可执行 `uv run scripts/generate_icons.py --platform linux`，随后重新构建并退出旧进程、启动新 bundle。

项目根目录的 `icon.png` 是控制端和受控端的应用图标母版。替换母版后执行：

```text
uv run scripts/generate_icons.py
```

脚本使用 PEP 723 声明 Pillow 依赖，由 `uv` 自动创建隔离环境。它会生成 Android launcher PNG、iPhone/iPad/App Store AppIcon、macOS AppIcon 和菜单栏 PNG、Windows 多尺寸 ICO，以及 Linux 窗口和托盘 PNG。

## 本地调试运行

先查看 Flutter 可用设备：

```text
flutter devices
```

Android：

```text
cd apps/mobile_app
flutter run -d <android-device-id>
```

iOS：

```text
cd apps/mobile_app
flutter run -d <ios-device-id>
```

Windows：

```text
cd apps/desktop_app
flutter run -d windows
```

macOS：

```text
cd apps/desktop_app
flutter run -d macos
```

正式构建统一使用前文的 `uv run python scripts/build.py ...`；这里直接调用 Flutter 仅用于连接设备和调试器的开发运行。控制端和受控端都在调试运行时，Windows 防火墙可能询问是否允许入站连接。开发阶段只允许专用网络。控制端连接的主机地址应使用受控端的局域网 IP，不能使用控制端设备自身的 `127.0.0.1`。

## 首次配对与使用

1. 启动受控端，从托盘或菜单栏打开状态窗口。受控端只允许运行一个实例；再次启动会唤醒已有实例的状态窗口。
2. 记录受控端状态页中的局域网地址、TLS SHA-256 指纹和当前 6 位安全码。
3. 控制端填入地址、端口、指纹和验证码。控制端会先固定证书指纹，再通过 TLS 发送 TOTP。
4. 配对成功后长期随机令牌保存到两端系统安全存储。控制端启动时只显示受控端列表，由用户选择要连接的设备。
5. 键盘页点击“受控端”可查看全部已保存的受控端，并可切换连接、主动断开、删除或添加；主动断开会立即取消连接尝试、退避计时和旧连接回调，不会再次自动重连。
6. 左侧键盘发送普通键和保持选中的组合键；右侧触控板支持单指移动光标、单击、双击、双指轻点右键，以及双指垂直/水平滚动。
7. 长按语音按钮录音，松开后由平台本地语音后端识别（Android 为 FunASR，iOS 为设备端 Speech framework）；结果只在点击“确认输入”后注入受控端当前激活窗口。

控制端切换网络后，旧控制流如果没有立即收到 TCP 断开通知，受控端会在 35 秒内因心跳超时主动释放旧会话，之后控制端可自动重连。

## 检查与测试

安装依赖后执行静态检查和测试：

```text
flutter analyze
flutter test packages/remote_input_core
flutter test packages/desktop_input_windows
flutter test apps/desktop_app
flutter test apps/mobile_app
```

不依赖 pub.dev 包的核心校验可以直接执行：

```text
dart tool/validate_core.dart
dart --packages=tool/validation_package_config.json tool/validate_windows_mapping.dart
```

预期输出分别包含：

```text
remote_input_core validation passed: 64 unique keys
Windows mapping validation passed: 76 keys, 8 modifiers
```

Linux 原生输入回归（需 clang++、GTK/X11/XTEST/GIO 开发包、Xvfb 和 dbus-run-session；Wayland 使用隔离模拟 portal，X11 使用隔离显示，不操作当前桌面）：

```text
uv run python scripts/test_linux_input.py
```

Python 工具语法检查：

```text
uv run python -m compileall -q scripts
```

## Android FunASR 模型与原生库

FunASR 接入参考 `D:\sources\zh-lang-textbook\app` 的 Android C ABI、后台 isolate 和模型提取方式。首次构建 Android 前准备模型和 arm64 原生静态库：

```text
uv run python scripts/prepare_funasr.py --build-native
```

默认参考仓库为 `D:\sources\zh-lang-textbook`；其他位置可使用：

```text
uv run python scripts/prepare_funasr.py --reference <zh-lang-textbook-root> --build-native
```

脚本会固定 FunASR 与 ONNX Runtime commit，复制 Paraformer/VAD 模型并生成 SHA-256 manifest。原生构建和 Flutter Android 工程统一使用 NDK 29.0.14206865，避免 C++ ABI 或工具链不一致。原生构建由本仓库的 Python 工具完成，只读取参考仓库已有的源码缓存，不在参考仓库写入文件，也不调用 `.sh`、`.bat`、`.cmd` 或 `.ps1`。产物写入 `native/asr/vendor/android-arm64-v8a/`。缺少原生产物时 Android 构建会直接失败，避免生成语音功能不可用的 APK。

首次原生构建需要编译 ONNX Runtime、RE2 和 FunASR，耗时较长。中间产物保存在 `.native-build/`，再次运行会复用已经完成的原生构建。准备脚本会把 ONNX、Protobuf、Abseil 等传递依赖一起合并，并使用 `--no-undefined` 实际链接 JNI 桥接库；链接校验失败时不会把原生包标记为可用。完成后再构建 APK：

```text
uv run python scripts/build.py --mode release android --android-format apk
```

模型准备流程由 `scripts/` 中的 Python 工具实现，并通过 uv 运行。模型工具会：

- 固定上游版本或 commit；
- 校验 SHA-256；
- 写入模型版本 manifest；
- 保留模型许可证和第三方 notices；
- 不把临时下载文件或开发机绝对路径写入发行物。

## GitHub Actions 构建与发布

仓库包含两组 workflow：

- `Build Android native dependencies` 仅支持手动运行，在 Ubuntu 上从固定 commit 构建并验证 Android arm64-v8a 的 FunASR/ONNX Runtime 静态依赖，然后更新当前仓库的 `natives` prerelease，上传 `native-android-arm64-v8a.tar.xz` 和 SHA-256 文件。iOS 使用系统 Speech framework，不需要也不发布 iOS native archive。
- `Build and publish release` 由 `v*` tag 触发，并行构建 Windows x64、macOS、Linux x64、Android arm64 APK 和未签名 iOS arm64 `.app`，全部成功后创建对应 tag 的 GitHub Release 并上传五个平台产物。

应用 Release workflow 不依赖开发机中被忽略的模型和 native 目录，而是从当前 GitHub 仓库下载两个固定 Release 资产：

```text
models/net-keyboard-trackpad-models.tar.xz
natives/native-android-arm64-v8a.tar.xz
```

模型压缩包必须在解压后产生 `speech/` 目录，因此可按以下布局制作并上传到当前仓库的 `models` Release：

```text
net-keyboard-trackpad-models.tar.xz
└─ speech/
   ├─ manifest.json
   ├─ funasr-paraformer-zh/
   └─ funasr-fsmn-vad/
```

创建本地模型资产后，可从仓库根目录打包：

```text
tar -cJf net-keyboard-trackpad-models.tar.xz \
  -C apps/mobile_app/assets speech
```

首次发布顺序：先创建 `models` Release 并上传模型压缩包，再手动运行 native workflow 生成 `natives` Release，最后推送版本 tag，例如 `v0.1.0`。Android 当前构建配置未提供独立 release keystore 时会使用开发签名；正式分发前仍需配置持久的 Android release keystore。iOS workflow 产物明确标记为 `unsigned`，安装或 App Store 发布需要另行签名；macOS 跨机器公开分发仍需 Developer ID 签名和公证。

## 常见问题

### 无法访问 pub.dev

`flutter pub get` 和 `dart pub global activate` 都需要终端进程能够访问 `https://pub.dev`。浏览器能够访问不代表终端代理配置一定相同。检查系统代理、`HTTP_PROXY`/`HTTPS_PROXY`、证书拦截和防火墙设置，再重新运行：

```text
uv run python scripts/bootstrap.py --skip-runners
```

### 找不到 protoc-gen-dart

重新激活固定版本插件：

```text
dart pub global activate protoc_plugin 25.1.0
```

`bootstrap.py` 会自动尝试把 Dart global pub cache 的 `bin` 目录加入当前子进程的 `PATH`。如果手工执行 `protoc`，则需要自行把该目录加入终端 `PATH`。

### Flutter 缺少 Android、iOS、Windows、macOS 或 Linux runner

重新执行：

```text
uv run python scripts/bootstrap.py --skip-doctor
```

脚本只生成缺失的 runner，并保留现有 app `pubspec.yaml`。

### iOS 无法安装未签名 Runner.app

默认 iOS 构建使用 `--no-codesign`，只用于验证编译。使用 Xcode 打开 `apps/mobile_app/ios/Runner.xcworkspace`，在 Runner 的 Signing & Capabilities 中选择 Development Team 并设置唯一 Bundle Identifier，然后运行 `uv run python scripts/build.py ios --mode release --ios-codesign`，或直接从 Xcode/Flutter 调试真机。

### Windows build 找不到 Visual Studio

打开 Visual Studio Installer，为现有安装增加 `Desktop development with C++` 工作负载，然后再次运行 `flutter doctor -v`。只有安装普通 Visual Studio Code 不足以编译 Flutter Windows 应用。

### Android licenses 未接受

执行：

```text
flutter doctor --android-licenses
```

完成后用 `flutter doctor -v` 确认 Android toolchain 不再报错。

### Kotlin 报 `this and base files have different roots`

Windows 上 Pub Cache 位于 C 盘而仓库位于 D 盘时，Kotlin 增量缓存无法把插件源码转换为相对于 Android 工程的路径。项目已在 `android/gradle.properties` 中关闭 Kotlin/JVM 增量编译；`build.py` 在 Android 构建前只删除遗留的 `caches-jvm` 目录，并保留 Flutter、CMake、FunASR 和 ONNX Runtime 产物。

## 开发约束

- 所有仓库脚本使用 Python，并由 uv 管理和执行。
- 不提交平台专属 shell、PowerShell 或批处理脚本。
- 协议使用语义键码，网络消息不得直接携带任意 Win32 virtual-key 或 scan code。
- 语音结果必须先在控制端展示；取消不发送，用户确认后才向受控端当前激活窗口发送 `TextInput`。
- 不在日志中记录 TOTP、token、TLS 私钥、完整按键内容、音频或语音识别文本。
- Windows 普通权限进程不能保证向管理员权限窗口、UAC 安全桌面、锁屏或登录界面注入输入。

