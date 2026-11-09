# 网络键鼠控制端与受控端实施规划

> 文档状态：实现中；macOS 与 Linux X11 受控端已接入，真机验收待完成
> 控制端：当前支持 Android，计划扩展 iOS
> 受控端：当前支持 Windows、macOS、Linux（X11）
> 实施原则：产品、协议和通用流程使用角色名称；系统名称只用于平台实现、构建和限制说明。

## 1. 产品目标

实现一套局域网远程输入工具。网络键鼠控制端显示可触控键盘、Fn 功能层、语音按钮和触控板，通过 gRPC 将输入命令发往网络键鼠受控端。受控端常驻后台，将收到的命令注入当前前台应用。

首版需要满足以下核心场景：

1. 用户在受控端状态窗口查看监听地址、端口和配对验证码。
2. 用户在控制端保存受控端的地址、端口并完成首次 TOTP 配对。
3. 控制端建立并维持由其发起的 gRPC 连接。
4. 用户点击普通键，受控端当前前台应用收到对应按键。
5. 用户切换 Ctrl、Alt、Shift、Meta 修饰键，再点击普通键，受控端收到组合键；修饰键保持选中，直到用户再次点击取消。
6. 用户长按语音按钮开始录音，松开后结束录音；控制端在本地识别并展示结果，只有用户明确点击“确认输入”后，受控端才将文本输入当前前台应用。
7. 受控端主窗口默认隐藏，通过托盘或菜单栏提供状态、配对、设置、断开和退出操作。

## 2. 范围

### 2.1 v1 必须实现

- 控制端：
  - 横屏键盘页面，完整显示本文定义的 64 键 ANSI-US 紧凑布局。
  - 额外的语音输入按钮。
  - 布局中出现的 Ctrl、Alt、Shift、Meta 修饰键具有可切换状态和明确视觉反馈。
  - IP/主机名、端口、设备名称、证书指纹、配对凭据的保存与管理。
  - 首次配对、自动重连、连接状态、错误反馈。
  - 本地麦克风录音、本地 FunASR 离线识别、最终文本提交。
  - 当前 Android 实现包含运行时麦克风权限处理。
  - 键盘左侧主区域与右侧触控板组合布局。
  - 触控板支持光标移动、单击、双击、双指轻点右键及双指横纵滚动。
- 受控端：
  - gRPC over TLS 监听服务。
  - 托盘或菜单栏图标及菜单。
  - 配对码显示、已配对设备管理、当前连接状态和监听端口查看。
  - 键盘组合键注入及 Unicode 文本注入。
  - 单实例、启动后隐藏到托盘、可选开机启动。
  - 本地滚动日志，日志不得包含验证码、令牌、证书私钥和完整语音内容。
- 共享部分：
  - 一份版本化的 Protocol Buffers 协议。
  - 控制端与受控端共享的语义键码、错误码和能力定义。
  - 协议生成、模型准备和应用打包脚本。

### 2.2 v1 明确不做

- iOS、Linux Wayland 的可运行产物。
- 系统输入法（IME）或悬浮键盘；控制端是独立前台应用。
- Windows 登录界面、锁屏、UAC 安全桌面中的输入。
- 对管理员权限应用的默认输入保证。
- 多个控制端同时控制；首版只允许一个活动控制会话。
- 互联网中继、NAT 穿透、云账户、远程发现服务。
- 音频上传到受控端或云端。
- 流式/边说边出字的语音结果。
- 剪贴板同步、文件传输、宏录制、自定义键盘布局编辑器。
- 游戏反作弊环境、Raw Input 独占程序或受保护应用的兼容保证。
- 系统服务模式；受控端进程运行在当前用户的交互会话中。

### 2.3 后续扩展方向

- 控制端的 `mobile_app` 增加 iOS runner，复用 UI、连接、协议和语音抽象层；另行提供 iOS 可用的本地语音识别原生构建。
- Linux Wayland 输入后端；当前 Linux runner 已实现 X11/XTEST、托盘及 Secret Service 凭据存储。
- 受控端输入能力通过平台接口扩展，协议中的语义键码保持不变。
- 多设备配对与控制权租约、鼠标/触控板、服务发现可作为独立版本演进，不影响 v1 的键盘消息。

## 3. 已确定的产品约定

### 3.1 “64 键”的精确定义

本项目固定使用 ANSI-US 64 键紧凑布局，共 64 个物理键位；语音按钮和触控板不计入 64 键。被精简的功能键通过 Fn 层提供，协议中的语义键码保持不变。

| 行 | 键位 | 数量 |
| --- | --- | ---: |
| R1 | Esc, `, 1–0, -, =, Backspace | 15 |
| R2 | Tab, Q–P, [, ], \\ | 14 |
| R3 | Caps Lock, A–L, ;, ', Enter | 13 |
| R4 | Left Shift, Z–M, ,, ., /, Right Shift, Up | 13 |
| R5 | Left Ctrl, Left Meta, Left Alt, Space, Right Alt, Fn, Left, Down, Right | 9 |
| 合计 |  | **64** |

约定：

- 布局标签采用 ANSI-US；字符最终结果由受控端当前键盘布局决定。
- `Fn` 是控制端本地锁定式层切换键，不向受控端发送；再次点击取消。
- Fn+1–0 映射 F1–F10，Fn+-/= 映射 F11/F12。
- Fn+Backspace 映射 Delete，Fn+P 映射 Print Screen，Fn+[ / ] 映射 Home/End，Fn+\\ 映射 Menu，Fn+Up/Down 映射 Page Up/Page Down。
- Fn+Left Ctrl 切换 Right Ctrl；协议保留右 Meta 修饰位，当前 64 键矩阵不显示该键。
- Caps Lock、Delete、Home、End、Page Up、Page Down、方向键等按普通功能键发送。
- 语音按钮放在键盘上方状态栏右侧，不能替换任何一个 64 键键位。

如果决定改用另一种 64 键矩阵，必须同时修改本节、Fn 映射、键码清单和验收用例，不能只改 UI。

### 3.2 修饰键状态

- 点击修饰键一次：控制端将其设为选中。
- 再次点击同一修饰键：取消选中。
- 选中状态会跨多个普通键保留，不在发送一次组合键后自动清除。
- 点击修饰键本身只改变控制端状态，不向受控端发送孤立的 key-down。
- 点击普通键时，控制端对当时所有选中的修饰键做快照，并发送一个原子 `KeyStroke` 命令。
- 受控端对每个 `KeyStroke` 依次执行：修饰键按下 → 主键按下 → 主键抬起 → 修饰键逆序抬起。
- 受控端不跨网络命令保持物理按键按下，因此断线、应用崩溃或丢包不会造成修饰键卡住。
- 控制端断开连接后保留 UI 选中状态，但键盘进入不可发送状态；重新连接后首次发送前仍显示这些状态。

### 3.3 普通按键和连发

- 字母、数字、符号、功能键：一次有效点击产生一个 `KeyStroke`。
- Backspace、Delete 和四个方向键支持长按连发。
- 连发建议参数：按住 400 ms 后开始，每 60 ms 发送一次；参数集中配置，后续可调。
- 每次连发仍是完整原子命令，不发送跨请求 key-down/key-up。
- Pointer cancel、页面失焦或应用进入后台时立即停止连发。
- 不做客户端离线队列。断线期间的点击直接失败并提示，恢复后不补发，避免把旧输入注入错误窗口。

### 3.4 语音按钮交互

- 按住达到 300 ms 后开始录音；达到阈值时震动一次并切换为“正在听”状态。
- 在 300 ms 前松开不录音，只提示“请长按说话”。
- 正常松开后停止录音，进入“识别中”；识别成功后打开结果审阅界面，不自动提交文本。
- 审阅界面完整显示待输入文本，并提供“取消”和“确认输入”两个明确操作。v1 文本只读，不在该界面提供编辑；后续可独立增加编辑能力。
- 点击“取消”时删除本次结果，不向受控端发送文本，并返回可录音状态。
- 点击“确认输入”时才发送识别文本；提交过程中禁用重复点击。成功后关闭审阅界面；失败时保留文本并回到审阅状态，用户可以重试或取消。
- 控制端返回操作、审阅弹窗外的取消手势按“取消”处理，不能隐式确认。
- 审阅期间连接断开时保留本次结果在内存中，但禁用“确认输入”；重连后只有用户再次明确点击确认才会发送。应用进程被系统终止后不恢复待确认文本。
- Pointer cancel、权限被撤销、应用进入后台或用户滑出取消区时取消录音并删除临时文件。
- 单次录音上限 60 秒，达到上限自动停止并识别。
- 开始录音前必须存在活动控制会话；录音或本地识别过程中断线仍可完成识别并展示结果，但确认按钮保持禁用，重连后也必须由用户手动确认，不自动补发。
- 空结果、仅空白结果或 VAD 未检测到有效语音时不向受控端发送。
- 待确认文本和最近一次发送结果只保留在内存中，不写普通日志。

### 3.5 文本输入目标约定

语音录制和识别完全发生在控制端本地，期间不在受控端建立或绑定目标窗口会话。控制端展示识别结果后：

1. 用户点击“取消”：仅清除控制端内存中的待确认文本，不发送网络命令。
2. 用户点击“确认输入”：控制端发送一个 `TextInput` 命令。
3. 受控端执行该命令时获取当下的前台激活窗口，并直接向该窗口注入文本。
4. 受控端不比较录音开始、录音结束或识别完成时的前台窗口；用户可以在确认前主动切换到希望接收文本的窗口。
5. 如果确认时没有可交互前台窗口，返回 `NO_FOREGROUND_TARGET`，控制端保留审阅文本供用户重试或取消。

普通按键也在命令到达受控端时作用于当下的前台窗口。

### 3.6 触控板和手势约定

- 控制端横屏主界面左侧约 70% 为 64 键键盘，右侧约 30% 为触控板。
- 单指移动：发送相对光标位移。
- 单指轻点：左键单击。
- 双指轻点：右键单击。
- 单指快速轻点两次：左键双击。
- 双指上下移动：垂直滚轮；双指左右移动：水平滚轮。
- 不识别捏合缩放和三指手势，避免与移动操作系统的系统手势冲突。
- 指针消息只传输相对位移、按钮状态和横纵滚轮增量，不发送平台常量或系统手势。
- Pointer cancel、应用进入后台或断线时必须清理触控状态，避免恢复后误触。

## 4. 总体架构

```text
网络键鼠控制端 Flutter app
├─ Keyboard UI / modifier state
├─ Connection & pairing controller
├─ gRPC client + TLS certificate pinning
├─ Recorder (mono WAV)
├─ FunASR Dart FFI facade
│  └─ 平台本地 ASR bridge + ONNX Runtime
└─ Secure profile storage
             │
             │ gRPC over TLS（控制端发起）
             ▼
网络键鼠受控端 Flutter app
├─ gRPC server / session manager
├─ Pairing & TOTP verifier
├─ Command validator / single-controller lease
├─ ControlledDeviceInput platform interface
│  └─ 平台输入注入实现
├─ Tray / settings window / autostart
└─ 安全凭据存储 + rolling logs
```

### 4.1 仓库建议结构

```text
net_keyboard_trackpad/
├─ apps/
│  ├─ mobile_app/                  # 网络键鼠控制端 Flutter app
│  │  ├─ android/
│  │  ├─ lib/
│  │  └─ assets/speech/
│  └─ desktop_app/                 # 网络键鼠受控端 Flutter app
│     ├─ windows/
│     ├─ macos/
│     └─ lib/
├─ packages/
│  ├─ remote_input_protocol/       # .proto、生成的 Dart 代码、协议常量
│  ├─ remote_input_core/           # 纯 Dart 状态模型、键码与校验逻辑
│  ├─ controlled_device_input/     # 受控端平台输入接口
│  ├─ desktop_input_windows/       # Windows 插件实现
│  └─ local_asr/                   # Dart API 与平台接口
├─ native/
│  └─ speech/                      # 从参考工程抽取的稳定 C ABI 与构建定义
├─ scripts/                        # uv 执行的跨平台 Python 自动化
├─ tool/                           # 工具版本和静态配置
├─ pyproject.toml                  # Python 工具环境，由 uv 管理
├─ uv.lock
├─ docs/
│  ├─ protocol.md
│  ├─ security.md
│  └─ release.md
├─ melos.yaml                      # 可选；统一管理多 package
└─ plan.md
```

两个角色使用独立 Flutter app，而不是在一个 app 中用运行平台判断角色。这样可分别管理权限、依赖、发布配置和生命周期，同时共享协议与领域模型。

### 4.2 层次边界

- UI 层只处理布局、手势和展示，不直接调用 gRPC、FFI 或系统输入 API。
- Controller/Application 层管理连接状态、修饰键、录音状态和命令确认。
- Domain 层保存平台无关的 `SemanticKey`、`ModifierSet`、会话状态和错误类型。
- Infrastructure 层实现 gRPC、持久化、FunASR 和平台输入。
- 受控端平台输入实现只接收已经校验的领域命令；协议消息不能直接传递任意平台键码。
- 仓库自动化统一使用 Python，并通过 `uv run` 执行；不提交 `.sh`、`.ps1`、`.bat` 或 `.cmd` 平台专属脚本。

## 5. 技术选型

版本号在项目初始化时依据当时 Flutter stable 和插件兼容性锁定，提交 `pubspec.lock`；本文不写浮动的“最新版”。

| 能力 | 建议实现 | 说明 |
| --- | --- | --- |
| UI | Flutter Material 3 | 两个独立 app，共享主题和领域 package |
| 状态管理 | Riverpod 或等价的显式 Controller | 连接、录音和键盘状态必须可测试；编码开始前固定一种 |
| RPC | `grpc` + `protobuf` Dart packages | 控制端为 client，受控端为 server；使用双向流作为活动会话 |
| TLS | gRPC TLS credentials + 自签名设备证书 + SHA-256 指纹固定 | 局域网内也不明文传验证码、令牌和输入内容 |
| 普通配置 | `shared_preferences` 或 JSON 配置文件 | 只保存非敏感 UI 设置、IP、端口、设备显示名 |
| Android 凭据 | Android Keystore 支持的 secure storage | 保存配对令牌和已确认的证书指纹 |
| Windows 凭据 | DPAPI（CurrentUser）封装 | 保存 TLS 私钥、TOTP secret、配对令牌哈希 |
| Android 录音 | `record` | 录制单声道 PCM WAV；参考工程已使用该路径 |
| Android ASR | FunASR Paraformer quantized ONNX + FSMN VAD，经 C ABI/FFI | 本地、离线、非流式首版 |
| 后台推理 | 独立 Dart isolate 调用 native FFI | 避免阻塞 Flutter UI isolate |
| Windows 输入 | 自有 Flutter Windows 插件调用 Win32 `SendInput` | 插件返回实际注入数量和错误；方便未来提供其他平台实现 |
| Windows 托盘 | 成熟的 Flutter tray 插件，外加窗口生命周期管理 | 依赖须在初始化阶段做最小原型验证 |
| 日志 | 结构化滚动文件 + 控制台 debug sink | 生产默认 info，保留最近若干文件并设总大小上限 |

## 6. FunASR 方案

### 6.1 参考工程核查结果

参考目录：`D:\sources\zh-lang-textbook\app`。

可复用的设计与资产组织：

- `lib/services/speech_engine.dart`
  - 使用 `record` 录制 WAV。
  - 单声道，24 kHz。
  - 将模型从 Flutter assets 提取到 application support 目录。
  - 识别后删除临时 WAV。
- `lib/services/native_inference.dart`
  - UI isolate 只传路径和字符串。
  - 原生推理放到独立 isolate，避免 UI 卡顿。
- `lib/services/speech_native.dart`
  - 通过稳定 C ABI 创建/销毁 ASR handle。
  - 调用 `zh_speech_asr_recognize_wav` 返回 UTF-8 文本。
- `native/speech/speech_bridge.h/.cpp`
  - 封装 Paraformer + FSMN VAD。
  - 对 Dart 暴露创建、销毁、识别 WAV 三个主要接口。
- `native/speech/VERSIONS.md`
  - FunASR 固定到 commit `231ec5dda739c83f35e59e875736cde3ef1af161`。
  - ASR 为 `funasr/Paraformer-large` quantized ONNX，VAD 为 `funasr/fsmn-vad-onnx`。
  - 明确记录 ONNX Runtime 和模型许可证。

当前参考模型大小约为：Paraformer 238.5 MB，FSMN VAD 0.52 MB，尚未计入原生库。该体积会显著影响 APK/AAB 和首次安装，必须在发布验收中记录最终包体。

### 6.2 v1 实现决定

- FunASR 运行在 Android，不运行在 Windows。
- 首版使用“录音完成后离线整句识别”，不做流式识别。
- 录音格式与参考实现保持一致：mono、24 kHz、PCM WAV；如果原生桥最终要求 16 kHz，则统一在录音端配置，不能临时在多处重采样。
- 模型 handle 懒加载；连接成功后可后台预热，以降低第一次语音输入延迟。
- 每次推理在后台 isolate 串行执行，一个应用进程只维护一个 ASR handle。
- ASR 结果 `.trim()` 后为空则视为无语音。
- 临时录音只保存在 cache 目录，成功、失败和取消路径都必须删除。
- 首个内部版本可随 APK 打包模型，以最短路径验证功能；`ModelStore` 必须抽象为“bundled asset / downloaded pack”两种来源，后续可改为首用下载而不改业务层。
- 模型文件使用版本 manifest 和 SHA-256 校验；不能仅凭文件大小判断是否完整。
- 复用参考工程时只提取 ASR、VAD、ONNX Runtime 相关部分，不带入 Piper、SNAC、OCR 依赖。
- 所有上游 commit、预编译产物来源、构建参数和许可证写入本项目 `native/speech/VERSIONS.md` 与发行包 notices。

### 6.3 ASR 状态机

```text
unavailable ──permission/model ready──> ready
ready ──long-press threshold──> recording
recording ──release──> recognizing
recognizing ──non-empty result──> reviewing
reviewing ──confirm──> submitting
submitting ──success ack──> ready
submitting ──retryable error──> reviewing
reviewing ──cancel──> ready
recording/recognizing/reviewing/submitting ──cancel/fatal error──> ready
any state ──app dispose──> disposed
```

同一时刻只允许一个录音或识别任务。状态迁移应带 operation id，忽略已取消操作的迟到回调。

可重试的网络或注入错误返回 `reviewing` 并保留文本；模型错误、空结果、用户取消和其他不可恢复错误进入 `ready`。

`reviewing` 状态只在控制端内存中保存识别文本。它不在受控端创建会话，也不设置自动提交计时器。连接可用时“确认输入”按钮才启用，用户确认是提交文本的唯一入口。

## 7. gRPC 协议规格

### 7.1 传输和版本

- 传输：HTTP/2 gRPC over TLS。
- 受控端默认监听：`0.0.0.0:39091`；端口可配置，修改后重启监听服务。
- 受控端显示可用局域网 IPv4 地址；控制端支持 IP 或主机名。
- 协议版本使用 `major.minor`：
  - major 不同：拒绝连接，返回 `INCOMPATIBLE_PROTOCOL`。
  - major 相同、minor 不同：按双方能力交集运行。
- 所有业务 RPC 设置 deadline；配对 10 秒、打开会话 10 秒、普通命令 3 秒、文本提交 10 秒。
- 单条消息限制在合理范围内；服务端配置接收上限，不能依赖库的默认无限/大上限。

### 7.2 服务草案

以下为接口语义草案，编码阶段应落成唯一的 `.proto`，字段编号发布后不得复用：

```proto
service RemoteInputService {
  rpc GetServerInfo(ServerInfoRequest) returns (ServerInfoResponse);
  rpc CreatePairingChallenge(PairingChallengeRequest)
      returns (PairingChallengeResponse);
  rpc Pair(PairRequest) returns (PairResponse);
  rpc Control(stream ClientEnvelope) returns (stream ServerEnvelope);
}
```

`GetServerInfo` 只返回非敏感信息：server id、显示名、协议版本、证书指纹、能力列表和是否允许配对。它不返回 TOTP。

`CreatePairingChallenge` 返回短时 challenge id、过期时间和服务端随机 nonce。受控端状态页常驻显示当前 6 位安全码，由用户在控制端手动输入；安全码仍按 TOTP 周期变化，服务端保留失败次数限制和临时锁定。

`Pair` 至少包含：

- `challenge_id`
- `client_instance_id`（控制端安装实例 UUID）
- `client_name`
- `totp_code`（固定 6 位字符串，保留前导零）
- `client_nonce`
- 客户端协议版本

成功响应至少包含：

- `paired_device_id`
- 256 bit 随机 bearer token（只在此次响应返回明文）
- server id、协议版本、能力列表
- token 创建时间

`Control` 是由控制端发起并保持的双向流。调用 metadata 包含 device id 和 bearer token。首条消息必须是 `ClientHello`，受控端回复 `ServerHello` 后才可发送命令。

### 7.3 流消息

```proto
message ClientEnvelope {
  uint64 sequence = 1;
  string event_id = 2; // UUID，重试去重
  oneof payload {
    ClientHello hello = 10;
    KeyStroke key_stroke = 11;
    TextInput text_input = 12; // 仅由语音结果审阅页的用户确认动作产生
    Ping ping = 13;
  }
}

message ServerEnvelope {
  uint64 acknowledged_sequence = 1;
  oneof payload {
    ServerHello hello = 10;
    CommandResult result = 11;
    VoiceInputStarted voice_started = 12;
    Pong pong = 13;
    SessionClosing closing = 14;
  }
}
```

关键字段约束：

- `sequence` 在一个 Control 流内从 1 单调递增；重复或倒退消息被拒绝。
- `event_id` 用于短时去重。受控端保存最近 256 个 event id 或最近 5 分钟记录，取先到条件；重复事件返回原结果，不再次注入。
- 受控端按接收顺序串行执行输入命令，不能并行调用平台输入 API。
- `KeyStroke` 包含一个 `SemanticKey` 和 modifier bitset，不包含任意 virtual-key/scan-code 数值。
- `TextInput.text` 使用 UTF-8 protobuf string，最大 16 KiB，并限制 Unicode scalar/code point 数；拒绝 NUL 和不允许的控制字符。
- `Ping` 每 10 秒发送；30 秒没有任何有效消息则关闭会话。具体数值集中配置。
- 服务端只授予一个 active controller lease；第二台设备可建立 TLS/认证，但打开 Control 时返回 `CONTROLLER_BUSY`。

### 7.4 语义键码

`SemanticKey` 至少覆盖第 3.1 节的所有可发送键。枚举按功能分组：

- `ESCAPE`, `F1`…`F12`
- `PRINT_SCREEN`, `DELETE`, `HOME`, `END`, `PAGE_UP`, `PAGE_DOWN`
- `BACKQUOTE`, `DIGIT_1`…`DIGIT_0`, `MINUS`, `EQUAL`, `BACKSPACE`
- `TAB`, `KEY_A`…`KEY_Z`, `BRACKET_LEFT`, `BRACKET_RIGHT`, `BACKSLASH`
- `CAPS_LOCK`, `SEMICOLON`, `QUOTE`, `ENTER`
- `COMMA`, `PERIOD`, `SLASH`, `SPACE`, `MENU`
- `ARROW_LEFT`, `ARROW_RIGHT`, `ARROW_UP`, `ARROW_DOWN`

修饰键不作为主键出现在 v1 `KeyStroke`，通过 bitset 表达：

- `LEFT_CTRL`, `RIGHT_CTRL`
- `LEFT_ALT`, `RIGHT_ALT`
- `LEFT_SHIFT`, `RIGHT_SHIFT`
- `LEFT_META`, `RIGHT_META`（v1 键盘只显示左 Meta，右侧位为协议预留）

协议中保留 `SEMANTIC_KEY_UNSPECIFIED = 0` 并拒绝执行。枚举值一经发布只能追加，不能改号或复用。

### 7.5 结果和错误码

每个输入命令都返回结构化结果：`event_id`、状态、错误码、可展示消息和可选诊断字段。至少定义：

- `OK`
- `UNAUTHENTICATED`
- `PAIRING_DISABLED`
- `PAIRING_EXPIRED`
- `INVALID_TOTP`
- `RATE_LIMITED`
- `CERTIFICATE_CHANGED`
- `INCOMPATIBLE_PROTOCOL`
- `CONTROLLER_BUSY`
- `INVALID_SEQUENCE`
- `DUPLICATE_EVENT`
- `UNSUPPORTED_KEY`
- `INVALID_TEXT`
- `NO_FOREGROUND_TARGET`
- `INPUT_BLOCKED`
- `INPUT_PARTIAL`
- `INTERNAL_ERROR`

面向 UI 的中文文案由控制端根据错误码生成，不能把受控端异常堆栈直接展示或跨网络返回。

## 8. 配对、TOTP 与 TLS

### 8.1 威胁边界

首版面向可信局域网，但仍需防止同网段设备窃听输入、重放验证码、伪装受控端或未经授权控制键鼠。TOTP 本身不提供传输加密，因此必须与 TLS、证书指纹确认、短时 challenge、限速和长期随机 token 一起使用。

### 8.2 受控端首次启动

1. 生成稳定的 `server_id`。
2. 生成自签名 TLS 证书和私钥，证书包含 server id；记录 SHA-256 指纹。
3. 生成至少 160 bit 随机 TOTP secret。
4. 使用平台安全存储保护私钥、TOTP secret 和配对 token 数据；Windows 使用 DPAPI，macOS 使用 Keychain，Linux 使用 Secret Service（需桌面提供并解锁）。
5. 状态页常驻显示当前 6 位安全码；新增设备仍须通过证书指纹固定、短时 challenge、TOTP 校验和失败限流。

### 8.3 首次配对流程

1. 受控端配对窗口显示：服务名、IP、端口、TLS SHA-256 指纹、当前 6 位验证码、剩余秒数。
2. 控制端新建受控端配置，输入 IP/端口并连接。
3. 控制端获取受控端证书和 `GetServerInfo`，显示证书指纹。
4. 用户确认两端显示的指纹一致；确认后控制端固定该指纹。
5. 控制端请求 pairing challenge，用户输入受控端当前显示的 6 位码。
6. 受控端校验 challenge、TOTP、限速、协议版本和证书所处会话。
7. 成功后签发随机 bearer token；控制端存入平台安全存储，受控端只保存 token 哈希。
8. 配对成功即消费 challenge，并关闭或刷新当前配对操作；同一 challenge 不能再次使用。

### 8.4 TOTP 参数和防暴力策略

- 标准：RFC 6238。
- 位数：6。
- 时间步长：30 秒。
- HMAC：首版固定 SHA-256；如果需要兼容通用 Authenticator，再评估 SHA-1。
- 接受窗口：当前时间步和前一个时间步，解决用户在边界输入的延迟；不接受未来时间步。
- 每个 pairing challenge 只允许一次成功，且有短时有效期。
- 单 IP/单 challenge 连续失败 5 次后锁定 60 秒；继续失败使用指数退避，配对窗口显示状态。
- 使用常量时间比较验证码和 token 哈希。
- 不在日志中记录 TOTP、TOTP secret 或 bearer token。
- 受控端系统时间异常时在配对窗口提示检查时间。

### 8.5 后续连接

- 已配对设备使用 bearer token，不需要每次人工输入 TOTP。
- 控制端校验证书指纹；指纹改变时停止连接并要求用户重新核对/配对，绝不静默接受。
- 受控端可在“已配对控制端”中撤销单个设备；撤销立即关闭其活动流。
- 控制端删除配置时同时删除本地 token 和指纹。
- token 没有固定短过期时间，但可由用户撤销；后续可增加轮换而不改变配对语义。

## 9. Windows 输入注入规格

### 9.1 键盘注入

- 使用 Win32 `SendInput`，每个命令组装为一个连续 `INPUT[]` 批次。
- 物理键优先使用 scan code，并对方向键、Delete、Home、End、Page Up/Page Down、右 Alt/右 Ctrl 等设置正确的 extended-key 标志。
- 插件维护唯一的 `SemanticKey -> Windows scan code/flags` 映射表。
- 修饰键按稳定顺序按下：Ctrl → Alt → Shift → Meta；按相反顺序抬起。
- 注入前读取相关实际键状态，避免用户物理按键与远程按键冲突；首版策略必须保守，不能为了“修正”而擅自抬起用户正在按的实体键。
- 检查 `SendInput` 返回的已插入事件数量：全部成功为 `OK`，0 为 `INPUT_BLOCKED`，部分成功为 `INPUT_PARTIAL` 并记录诊断。
- 所有调用经一个串行队列执行，保证不同网络命令不交错。

### 9.2 Unicode 文本注入

- ASR 文本使用 `KEYEVENTF_UNICODE` 逐 UTF-16 code unit 发送 key-down/key-up。
- 正确处理非 BMP 字符的 surrogate pair。
- 允许普通 Unicode、空格和由产品策略允许的换行；拒绝 NUL 和其他危险/无意义控制字符。
- Windows 在收到 `TextInput` 时获取当下前台窗口并开始注入；不与录音或识别阶段的历史窗口比较。任何注入失败立即停止并返回部分失败。
- 首版不通过剪贴板粘贴，避免覆盖用户剪贴板和泄漏内容。
- 某些控制台、游戏、Raw Input 应用可能不接受 `KEYEVENTF_UNICODE`，应在兼容性文档中列明，不在 v1 用剪贴板兜底。

### 9.3 Windows 权限限制

`SendInput` 受 UIPI 限制：普通权限进程通常只能向相同或更低完整性级别的进程注入。首版 Windows app 默认以普通用户权限运行，因此不承诺向“以管理员身份运行”的目标应用输入，也不能向 UAC 安全桌面、登录界面或锁屏输入。

不应默认要求桌面 app 以管理员权限启动。若未来确实需要覆盖高完整性目标，应单独设计签名、UIAccess、安装位置和安全审查，不能在 v1 临时提权解决。

## 10. 网络键鼠控制端规格

### 10.1 页面

1. **受控端列表/连接页**
   - 已保存受控端卡片：名称、主机、端口、配对状态、最后连接结果。
   - 新增、编辑、删除、连接按钮。
2. **首次配对页**
   - 输入主机、端口、设备名称。
   - 展示受控端指纹并要求用户与受控端状态窗口核对。
   - 输入 6 位 TOTP，显示有效性和限速错误。
3. **键盘页**
   - 连接状态、延迟、当前受控端名称。
   - 64 键矩阵、Fn 层、语音按钮、选中修饰键提示。
   - 语音识别结果审阅弹窗或 bottom sheet，完整显示待输入文本，并提供“取消”“确认输入”。
   - 最近提交结果/错误的短时状态条。
4. **设置页**
   - 自动重连、震动、按键音、连发参数、模型信息、日志导出（脱敏）。

### 10.2 布局和可用性

- 键盘页锁定横屏；竖屏显示旋转提示，其他配置页可使用竖屏。
- 使用“键宽单位”描述布局，Backspace、Tab、Caps、Enter、Shift、Space 等按 ANSI 比例加宽。
- 视觉组件和手势命中组件分离；按下态必须在一帧内反馈。
- 目标设备基线应在编码前固定，例如不小于 6.1 英寸、1080p 横屏。84 键同时显示会使触控目标小于通用 48 dp 建议值，必须用真机可用性测试确认最小命中尺寸。
- 小于基线宽度时优先等比压缩并显示“不推荐尺寸”提示；首版不隐藏键位，也不把键盘拆成多页。
- 系统导航栏/刘海安全区不能覆盖外侧键。
- 修饰键选中态除颜色外还应有边框或图标，兼顾色觉差异。
- 连接中断时保留布局但整体进入禁用态，顶部给出明确原因和重连状态。

### 10.3 连接状态机

```text
disconnected -> resolving -> tlsConnecting -> authenticating
-> openingControl -> connected

任意中间状态 -> error -> backoff -> resolving
connected -> connectionLost -> backoff
certificateChanged -> userActionRequired
revoked/unauthenticated -> pairingRequired
```

- 自动重连退避建议：1、2、4、8、15、30 秒，之后保持 30 秒并加入抖动。
- 应用启动时只加载并显示已保存受控端，不自动连接上次使用的受控端。
- 用户主动断开时立即作废当前连接代次，取消正在进行的连接、退避计时和迟到回调，不自动重连。
- 受控端对控制流启用 35 秒无消息超时；控制端切换网络造成旧流未及时关闭时，受控端主动释放旧会话，允许控制端重新连接。
- 控制端应用进入后台后关闭活动 Control 流；回到前台再重连。首版不依赖后台常驻。
- 每次重连创建新 sequence 空间和新的控制租约。

## 11. 网络键鼠受控端通用规格

### 11.1 生命周期

- 单实例；第二次启动通知现有实例打开设置/状态窗口后退出。
- 正常启动后创建托盘或菜单栏图标、启动 gRPC server，然后隐藏主窗口。
- 点击窗口关闭按钮时隐藏到后台；只有菜单中的“退出”真正停止服务并结束进程。
- 退出顺序：停止接受新 RPC → 通知并关闭活动会话 → 停止 server → 销毁 tray → 释放资源。
- 系统睡眠/唤醒、网络地址变化后刷新状态页地址；必要时重启 listener。

### 11.2 托盘或菜单栏菜单

- `状态：正在监听 / 已连接 / 错误`（禁用项）。
- `监听：0.0.0.0:39091`（禁用项）。
- `本机地址` 子菜单，列出可用局域网 IPv4，可复制。
- `打开状态窗口`，查看连接地址、证书指纹和当前安全码。
- `已配对控制端…`，查看、撤销控制端。
- `断开当前控制端`，无连接时禁用。
- `设置…`，配置端口、开机启动、日志级别等。
- `开机启动`，可勾选。
- `打开日志目录`。
- `退出`。

tooltip 简短显示 app 名称、端口和连接状态。不能把 TOTP 直接长期显示在 tooltip 或菜单项中；验证码只在显式打开的配对窗口显示。

### 11.3 设置窗口

- 监听端口，范围 1024–65535；保存前检查占用。
- 绑定范围：v1 默认所有接口；可选仅指定接口属于后续增强。
- 开机启动。
- 服务名称。
- TLS 指纹查看和复制。
- 已配对控制端列表：名称、首次配对时间、最后连接时间、撤销。
- 当前连接：远端地址、连接时长、最近心跳。
- 日志目录、版本、协议版本。

### 11.4 防火墙与安装

- 首次监听可能触发 Windows Defender Firewall 提示；文档明确只勾选专用网络。
- 如果安装器创建入站规则，规则必须只针对应用可执行文件和所选 TCP 端口，并由用户在安装流程明确选择。
- 便携版不自动修改防火墙。
- 修改端口后同步提示更新防火墙规则；应用本身不静默申请管理员权限。

## 12. 数据与配置

### 12.1 控制端配置

非敏感配置：

```text
profile_id
display_name
host
port
server_id
last_connected_at
ui_preferences
```

安全存储：

```text
profile_id -> paired_device_id
profile_id -> bearer_token
profile_id -> pinned_certificate_sha256
```

### 12.2 受控端配置

普通配置文件：

```text
listen_port
server_display_name
autostart
log_level
config_schema_version
```

平台安全存储保护的数据：

```text
server_id
tls_private_key
tls_certificate
totp_secret
paired_devices[]: device_id, display_name, salted_token_hash, timestamps, revoked
```

配置写入使用临时文件 + 原子替换。升级时按 `config_schema_version` 迁移；迁移失败保留原文件并进入只读错误状态，不能重置凭据后继续监听。

## 13. 性能和质量目标

- 已连接局域网内，按键从控制端 pointer-up 到受控端调用注入的 p95 目标小于 80 ms；UI 本地按下反馈小于一帧。
- Control 流稳定运行 8 小时不泄漏连接、timer 或 native handle。
- 连续 1,000 次按键命令顺序一致，无重复、无丢失；网络断开时允许当前未确认命令失败，但不能重连后误重放。
- ASR 推理不阻塞 UI；识别期间动画和取消操作保持响应。
- 语音首轮模型加载时间、稳态识别耗时、峰值内存和安装包体积在发布报告中量化，不提前写不现实的固定数值。
- 受控端空闲时 CPU 接近 0，内存稳定；控制端非录音状态不占用麦克风。
- 所有 native handle、stream subscription、timer、recorder 和临时文件都有明确释放路径。

## 14. 测试与验收策略

### 14.1 单元测试

- 64 键布局恰好包含 64 个唯一 key id；基础层与 Fn 层合计覆盖完整语义键集合。
- 修饰键切换、组合快照和断线状态。
- 连发启动、停止、pointer cancel 和页面销毁。
- 语音 `recording -> recognizing -> reviewing -> submitting` 状态迁移；取消不产生 `TextInput`，确认只产生一次命令，提交失败保留待确认文本。
- 连接状态机、重连退避、用户主动断开。
- sequence、event id 去重和服务端串行队列。
- TOTP RFC 测试向量、前导零、时间窗口、challenge 消费和限速。
- 文本长度、UTF-8/UTF-16、控制字符和 surrogate pair 校验。
- 配置迁移和损坏配置处理。

### 14.2 协议集成测试

- 使用进程内或 loopback gRPC server/client 验证 TLS、配对、token 认证和 Control 流。
- 错误证书、变化的指纹、错误/过期 TOTP、被撤销 token。
- major 版本不兼容和 minor 能力协商。
- 重复 event id 只注入一次。
- 第二活动控制器收到 `CONTROLLER_BUSY`。
- 心跳超时释放控制租约。
- `TextInput` 只在控制端用户确认后出现；相同 event id 重试不会重复注入。
- 消息过大、非法枚举、乱序 sequence 被拒绝但 server 不崩溃。

### 14.3 受控端平台输入测试

- 对每个 `SemanticKey` 校验 scan code、extended flag 和 down/up 顺序。
- 左右 Ctrl/Alt/Shift/Meta 分别验证。
- 典型组合：Ctrl+C、Ctrl+Shift+Esc、Alt+Tab、Win+R、Ctrl+Alt+Delete 的行为说明。
  - 注意：Ctrl+Alt+Delete 属于安全注意序列，普通 `SendInput` 无法触发；测试应确认失败/无效果符合系统边界，而不是把它列为支持能力。
- Unicode：中文、英文、标点、emoji/非 BMP 字符。
- 在录音或审阅期间切换受控端前台窗口，点击确认后文本进入确认时的当前窗口。
- 普通目标、管理员目标、UAC/锁屏边界行为有明确结果。

### 14.4 控制端真机测试

- Android 最低支持版本、主流版本各至少一台 arm64 真机。
- 横屏尺寸、刘海/挖孔、系统三键/手势导航。
- 麦克风首次授权、拒绝、永久拒绝、录音中撤销。
- 短按语音按钮不录音，长按开始，松开停止，取消手势删除文件。
- 中文普通话、静音、噪声、超时、模型缺失/损坏、低存储空间。
- 识别结果审阅时取消不发送；确认发送一次；提交失败后文本仍可重试或取消。
- 识别期间断网、受控端退出、控制端切后台。

### 14.5 端到端验收矩阵

受控端目标应用至少包括：

- Windows 记事本：字母、数字、符号、中文语音、换行。
- 浏览器地址栏/网页输入框：组合键和 Unicode。
- 文件资源管理器：方向键、Home/End、Delete、F2 等。
- Windows Terminal：功能键和组合键；记录 Unicode 兼容差异。
- 一个以管理员身份运行的编辑器：确认普通权限 app 返回/表现出已知限制。

发布门槛：所有 P0/P1 用例通过；已知平台限制写入 README；不存在会导致修饰键卡住、命令重放或文字输入错误窗口的已知缺陷。

## 15. 可观测性与故障诊断

- 每个 Control 流生成 session id；每个命令记录 event id 的短前缀、类型、耗时和结果码。
- 不记录具体按键内容的完整序列；默认只记录命令类型和结果，debug 模式也不得记录 bearer token/TOTP。
- 语音日志只记录阶段、音频时长、模型版本、耗时、结果字符数和错误码，不记录音频或识别文本。
- 受控端日志包含 listener 启停、连接来源 IP、配对控制端 id、证书/协议错误和平台输入结果。
- 控制端提供脱敏诊断导出：版本、设备 ABI、模型版本、连接状态迁移、错误码。
- 日志滚动上限建议总计 20 MB，实际值在实现阶段集中配置。

## 16. 任务清单

以下任务按依赖顺序执行。每个阶段结束都要满足 Exit Criteria，再进入下一阶段。

### Phase 0：决策与最小技术验证

- [x] 确认第 3.1 节 64 键矩阵及 Fn 行为为最终产品约定。
- [ ] 固定 Flutter stable、Dart、Android NDK/CMake、Windows Visual Studio toolchain 和 protoc 版本。
- [ ] 决定状态管理方案并记录架构约定。
- [ ] 在最小 Flutter Windows demo 中验证 gRPC Dart server 可监听局域网地址并使用自签名 TLS。
- [ ] 在最小 Windows 插件中验证 `SendInput`：普通键、扩展键、左右修饰键、中文 Unicode。
- [ ] 验证托盘插件：右键菜单、关闭到托盘、真正退出、单实例。
- [ ] 从参考项目裁剪 ASR-only 原生依赖，在 Android arm64 真机完成一次 WAV 识别。
- [ ] 记录 ASR 原生库大小、模型大小、冷启动耗时、稳态耗时和峰值内存。
- [ ] 确认发行方式基线：内部侧载 APK/EXE，或需要商店发布；据此决定模型首版是否可随包分发。

Exit Criteria：四个高风险点（gRPC server、SendInput、托盘、Android FunASR）都有独立可运行 spike 和书面结论；没有未验证的核心依赖。

### Phase 1：仓库和共享协议

- [ ] 创建两个 Flutter app 与共享 packages 目录。
- [ ] 配置 workspace/melos、统一 lint、format 和构建命令。
- [ ] 编写 `remote_input.proto`，落实字段号、枚举、错误码和版本策略。
- [ ] 添加由 uv 执行的跨平台 Python protoc + Dart codegen 脚本，生成文件可重复构建。
- [ ] 实现纯 Dart `SemanticKey`、modifier bitset、能力模型和转换层。
- [x] 建立 64 键声明式布局和 Fn 映射数据，增加唯一性和数量测试。
- [ ] 写 `docs/protocol.md` 与兼容性规则。
- [ ] 配置 CI：format、analyze、unit test、proto drift check。

Exit Criteria：client/server 可通过 loopback TLS 完成 hello、发送模拟命令并收到 ack；协议生成无手工步骤。

### Phase 2：受控端基础应用

- [ ] 实现单实例和隐藏窗口生命周期。
- [ ] 初始化托盘图标、tooltip 和第 11.2 节菜单。
- [ ] 实现设置窗口与端口占用校验。
- [ ] 实现配置文件原子写入和 schema migration。
- [ ] 实现 DPAPI secret store。
- [ ] 首次运行生成 server id、TLS 证书、TOTP secret。
- [ ] 启动/停止 gRPC TLS server，显示监听地址和错误。
- [ ] 实现结构化滚动日志。
- [ ] 实现可选开机启动及状态同步。
- [ ] 编写防火墙和普通权限限制说明。

Exit Criteria：受控端可长时间后台运行、监听指定端口、重启后保留身份和证书，退出时干净释放端口。

### Phase 3：配对和会话安全

- [x] 实现状态页常驻安全码、短时配对 challenge 和失败限流。
- [ ] 实现 TOTP 生成/验证和 RFC 测试向量。
- [ ] 实现 pairing challenge 创建、过期、一次性消费。
- [ ] 实现失败限速和锁定状态展示。
- [ ] 实现 bearer token 签发、哈希存储、验证和撤销。
- [ ] 控制端实现证书指纹显示、人工确认和 pinning。
- [ ] 控制端实现安全存储及受控端配置增删改。
- [ ] 实现协议版本协商和能力返回。
- [ ] 实现 Control 流认证、单 controller lease、heartbeat 和超时。
- [ ] 实现设备撤销后立即断开活动会话。

Exit Criteria：未配对、错误证书、错误验证码、重放 challenge、被撤销设备均不能建立控制流；正确设备可重启两端后自动认证。

### Phase 4：受控端输入引擎

- [x] 建立 `ControlledDeviceInputInjector` 平台接口。
- [ ] 实现 Windows C++ 插件与 `SemanticKey` 映射。
- [ ] 实现 scan code、extended flag 和左右修饰键。
- [ ] 实现单批次原子 `SendInput` 和串行执行队列。
- [ ] 校验全部/部分/零注入并映射错误码。
- [ ] 实现 Unicode UTF-16 注入及 surrogate pair。
- [ ] 实现文本长度/控制字符校验和分批注入。
- [ ] 实现 event id 去重缓存和 sequence 校验。
- [ ] 实现 `TextInput` 执行时获取当前前台窗口及无可用目标时的错误返回。
- [ ] 完成目标应用兼容性手工测试矩阵。

Exit Criteria：84 键中所有可发送键均有确定映射；典型组合键和中文文本在普通权限目标中工作；任何失败都返回结构化结果。

### Phase 5：控制端键盘和连接

- [ ] 实现设备列表、新建/编辑、配对和连接页面。
- [ ] 实现连接状态机、deadline、heartbeat 和指数退避。
- [x] 实现声明式 64 键布局、Fn 功能层和 ANSI 宽度单位。
- [ ] 实现普通点击、按下视觉反馈、pointer cancel。
- [ ] 实现左右修饰键复选状态和一键清除。
- [ ] 实现 Backspace/Delete/方向键长按连发。
- [ ] 实现 `KeyStroke` 发送、ack 对应和错误提示。
- [ ] 断线时禁用输入并确保不排队补发。
- [ ] 适配安全区、目标横屏尺寸和系统导航模式。
- [ ] 增加震动/按键音设置；默认按键音可关闭。

Exit Criteria：在两台不同尺寸 Android 真机上，可连续完成全部按键、修饰组合和连发操作，无重复命令、无卡键、无明显误触。

### Phase 6：控制端 FunASR 语音输入

- [ ] 从参考项目抽取 ASR-only C ABI、FFI facade 和构建文件。
- [ ] 固定并记录 FunASR、ONNX Runtime、模型版本、校验值和许可证。
- [ ] 实现 `ModelStore`、asset 提取、版本 manifest 和 SHA-256 校验。
- [ ] 实现后台 isolate、ASR handle 懒加载/预热和释放。
- [ ] 实现麦克风权限完整流程。
- [ ] 实现 300 ms 长按、震动、录音态、取消区、60 秒上限。
- [ ] 录制 mono PCM WAV，并确认采样率与 bridge 一致。
- [ ] 实现临时文件在成功/失败/取消后的清理。
- [ ] 实现识别结果审阅界面；只有“确认输入”生成 `TextInput`，取消不发送命令。
- [ ] 实现空语音、模型损坏、存储不足、识别失败和断线提示。
- [ ] 测量首轮和稳态识别性能、内存和功耗。

Exit Criteria：普通话语音可离线识别并展示；取消时不发送任何文本，确认后输入受控端当下的前台窗口；识别期间 UI 流畅且临时音频不残留。

### Phase 7：加固、打包和发布准备

- [ ] 完成单元、协议集成、插件和端到端测试。
- [ ] 进行 8 小时连接稳定性和 1,000 次输入顺序测试。
- [ ] 检查日志、崩溃报告、配置中无敏感明文。
- [ ] 检查 APK ABI，只发布实际有原生库支持的 ABI；首版建议明确 arm64-v8a。
- [ ] 生成各控制端和受控端平台的签名发行包。
- [ ] 汇总第三方 notices、模型许可证和源码义务。
- [ ] 编写用户 README：安装、配对、防火墙、使用、撤销、已知限制。
- [ ] 编写开发文档：环境、模型准备、proto 生成、构建和故障排查。
- [ ] 记录最终包体、内存、延迟和兼容性矩阵。
- [ ] 安全审查：证书 pinning、token 存储、TOTP 重放、限速、消息上限、输入校验。

Exit Criteria：干净的控制端与受控端设备可按文档安装并完成配对；P0/P1 验收项全部通过；发行物可复现且许可证齐全。

## 17. 编码前必须关闭的决策项

以下不是阻塞本文完成的疑问，但必须在 Phase 0 形成明确记录：

1. 第 3.1 节的 64 键矩阵和 Fn 映射已经确定；后续变更必须同步更新布局校验。
2. 最低 Android 版本、最低屏幕尺寸和是否只支持 arm64-v8a。
3. 首版发行渠道；约 239 MB ASR 模型是随包携带还是首次使用下载。
4. 受控端默认端口是否使用 39091。
5. 状态管理和托盘插件的最终选择，以 spike 结果为准。
6. TOTP 是否只由受控端配对窗口显示；本文默认不兼容第三方 Authenticator。

任何决策变化都应先更新本文相应规格和验收标准，再进入实现。

## 18. 主要风险与缓解措施

| 风险 | 影响 | 缓解 |
| --- | --- | --- |
| 64 键在小尺寸手机横屏仍可能过密 | 误触、不可读 | 固定目标屏幕基线、真机验证、声明式宽度单位 |
| FunASR 模型和 native 库体积大 | 安装包巨大、分发困难 | Phase 0 量化；抽象 ModelStore；内部版可 bundled，公开版切下载模型包 |
| ASR 冷启动慢/占内存高 | 首次语音体验差 | 连接后后台预热、单 handle、后台 isolate、性能门槛实测 |
| `SendInput` 受 UIPI/应用类型限制 | 管理员应用或游戏无输入 | 明确普通权限边界，返回错误，不静默提权，不承诺受保护应用 |
| 用户确认语音文本时受控端焦点不在预期窗口 | 文本进入错误位置 | 审阅界面明确提示“将输入到受控端当前窗口”；只在用户点击确认时发送，不自动提交或重试 |
| TOTP 被同网段窃听/重放 | 未授权输入 | TLS + 指纹 pinning + 单次 challenge + 限速 + 长期随机 token |
| TLS 自签名证书首次信任 | 可能遭遇首次连接中间人 | 两端人工核对 SHA-256 指纹，变化时强制重新确认 |
| 网络重试造成重复按键 | 重复输入 | 不自动重发未确认输入；event id 去重；sequence 单调 |
| 长期按住/断线造成卡键 | 受控端修饰键卡住 | 每个命令原子按下/抬起，服务端不跨命令保存物理 down 状态 |
| 受控端托盘/菜单栏插件生命周期问题 | 无法退出、重复进程 | Phase 0 spike、单实例、明确退出顺序和长稳测试 |
| 上游原生依赖许可证或构建不可复现 | 无法发布 | 固定 commit/版本、保存构建脚本和 checksums、发行前许可证审查 |

## 19. 参考资料

本地实现参考：

- `D:\sources\zh-lang-textbook\app\lib\services\speech_engine.dart`
- `D:\sources\zh-lang-textbook\app\lib\services\native_inference.dart`
- `D:\sources\zh-lang-textbook\app\lib\services\speech_native.dart`
- `D:\sources\zh-lang-textbook\app\native\speech\speech_bridge.h`
- `D:\sources\zh-lang-textbook\app\native\speech\speech_bridge.cpp`
- `D:\sources\zh-lang-textbook\app\native\speech\VERSIONS.md`

外部规范/文档：

- RFC 6238 TOTP：<https://www.rfc-editor.org/rfc/rfc6238>
- gRPC Dart basics：<https://grpc.io/docs/languages/dart/basics/>
- Dart `grpc` package：<https://pub.dev/packages/grpc>
- Win32 `SendInput`：<https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-sendinput>
- Win32 `KEYBDINPUT`：<https://learn.microsoft.com/windows/win32/api/winuser/ns-winuser-keybdinput>
- FunASR repository：<https://github.com/modelscope/FunASR>


## 20. macOS 受控端实现与验收

本节记录 macOS 受控端的平台实现；共享协议、TLS、TOTP 配对、单控制会话、去重与控制端本地语音确认流程保持适用。

- [x] 提取 `ControlledDeviceInputInjector` 平台接口，受控端等待异步原生注入，保持命令串行。
- [x] 增加 macOS Flutter runner、Swift MethodChannel 与 Core Graphics 输入实现。
- [x] 普通键、F1–F12、导航键、左右 Control/Option/Shift/Command 映射。
- [x] Meta 对应 Command；PrintScreen 对应 Command+Shift+3；Menu 对应 Shift+F10（由应用决定）。
- [x] Unicode 文本按 scalar 生成事件，保留 UTF-16 surrogate pair，不使用剪贴板。
- [x] 光标移动、单双击、右键、中键、横纵滚动和多显示器边界处理。
- [x] 辅助功能授权检查、用户主动授权入口；每次注入重新检查权限。
- [x] 菜单栏运行、关闭隐藏、单实例文件锁、重复启动唤醒窗口。
- [x] Keychain 存储（legacy Keychain，无共享 entitlement）；取消 App Sandbox 以支持系统输入。
- [x] Python bootstrap/build/icons 增加 macOS；`all` 按宿主选择桌面目标。
- [ ] 控制端 → macOS 受控端真机端到端验证：TextEdit、浏览器、Terminal、中文和 emoji。
- [ ] 权限首次拒绝/撤销/重新授予；菜单栏、双击、双轴滚动和多屏手工验收。
- [ ] 签名、公证、干净 Mac 安装、长连接与性能验收。

注入失败沿用 `INPUT_BLOCKED`，无前台目标沿用 `NO_FOREGROUND_TARGET`。macOS `CGEvent.post` 没有事件接收数量返回值，`injected_event_count` 只表示已提交的事件数量，不能保证目标应用处理成功。Secure Input、锁屏、登录界面和系统保护窗口不在保证范围。普通键受当前输入法影响；语音文本仅在控制端用户确认时发送到受控端当前窗口。

实现依据：[Apple CGEvent](https://developer.apple.com/documentation/coregraphics/cgevent) 和 [Unicode 事件](https://developer.apple.com/documentation/coregraphics/cgevent/keyboardsetunicodestring(stringlength:unicodestring:))。旧阶段清单是历史规划，未勾选项不表示本次已经验收。

## 21. Linux X11 受控端实现与验收

- [x] GTK Linux runner、单实例激活和托盘 PNG；复用 TLS、TOTP、配对与会话服务。
- [x] XTEST 原子按键（76 个语义键、8 个修饰键），相对鼠标、三键及双轴滚动。
- [x] 中文/emoji 使用剪贴板与 Shift+Insert；替换 CLIPBOARD 与 PRIMARY，目标需支持粘贴。
- [x] 凭据复用 flutter_secure_storage Linux Secret Service，不使用明文回退。
- [x] bootstrap/build 增加 linux；README 提供 openSUSE Leap X11 依赖与交付说明。
- [x] 隔离 Xvfb 原生回归：76 键映射、8 修饰键、组合键顺序、Unicode 双 selection、鼠标/滚轮、Wayland 与无焦点拒绝；现有 10 项 Flutter 回归通过。
- [ ] openSUSE Leap 16.1 X11 真机：配对、编辑器/浏览器/终端输入、权限/凭据服务失败、托盘与重复启动、重连、退出。

Wayland/XWayland 会话明确返回 INPUT_BLOCKED；不保证锁屏和登录界面。文本粘贴沿用控制端明确确认流程。ACK 仅表示 XTEST 事件提交，不保证目标应用消费；小额滚轮增量在原生端累计，未满一格时可返回零事件成功。

Linux Release 已成功构建，产物仅打包到项目内 bundle；窗口和任务栏图标通过 GResource 嵌入，Linux 退出流程避免提前销毁 Flutter 隐式视图。原生 runner/输入桥编译检查、修改的 Dart 文件静态分析及 Python 语法检查通过。用户已确认 Android 可以连接 Linux；完整输入与生命周期真机验收仍待完成。全仓库 analyze 仍有既有 lint 与 Android 模型 assets 缺失告警。
