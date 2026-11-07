# Toolchain versions

首轮开发环境：

- Flutter `3.44.0`（stable channel）
- Dart `3.12.1`
- protoc `31.1`
- protoc Dart plugin `25.1.0`
- CMake `4.1.2`
- Android NDK `29.0.14206865`
- Git for Windows `2.41.0`
- Python `3.12.11`
- uv `0.13.6`

Visual Studio toolchain 版本将在 Windows runner 的发行环境固定后补充。


macOS 受控端验证环境（2026-11-07）：

- Flutter `3.47.9`、Dart `3.13.7`
- Xcode `27.2`（27B52）、CocoaPods `1.17.0`
- macOS runner deployment target：`12.0`
- uv `0.13.7`；Python `3.15.2`（脚本仍声明兼容 Python 3.12）

已验证 Debug/Release `.app` 构建；桌面桥接/状态页、核心模型、Windows 映射共 9 项测试及 Android 启动测试通过。静态检查无 error/warning，存在历史 info lint。Python 编译与四种宿主/目标脚本路径校验通过；本机未安装 protoc，未执行完整 bootstrap/proto 重生成流程。辅助功能授权、Android→Mac 输入、签名公证和多屏体验待真机验收。
