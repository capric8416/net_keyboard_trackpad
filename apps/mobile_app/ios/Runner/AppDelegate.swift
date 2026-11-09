import Flutter
import Speech
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "OnDeviceSpeechPlugin"
    ) else { return }
    OnDeviceSpeechPlugin.register(with: registrar)
  }
}

private final class OnDeviceSpeechPlugin: NSObject, FlutterPlugin {
  private var recognitionTask: SFSpeechRecognitionTask?
  private var recognizer: SFSpeechRecognizer?
  private var pendingResult: FlutterResult?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "net_keyboard/speech",
      binaryMessenger: registrar.messenger()
    )
    let instance = OnDeviceSpeechPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ensureAuthorized":
      ensureAuthorized(result)
    case "recognizeFile":
      guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
        result(permissionError())
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let path = arguments["path"] as? String,
        !path.isEmpty
      else {
        result(FlutterError(
          code: "INVALID_AUDIO",
          message: "录音文件路径无效",
          details: nil
        ))
        return
      }
      recognize(
        path: path,
        locale: arguments["locale"] as? String ?? "zh-CN",
        result: result
      )
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func ensureAuthorized(_ result: @escaping FlutterResult) {
    switch SFSpeechRecognizer.authorizationStatus() {
    case .authorized:
      result(true)
    case .notDetermined:
      SFSpeechRecognizer.requestAuthorization { status in
        DispatchQueue.main.async {
          if status == .authorized {
            result(true)
          } else {
            result(self.permissionError())
          }
        }
      }
    case .denied, .restricted:
      result(permissionError())
    @unknown default:
      result(permissionError())
    }
  }

  private func recognize(
    path: String,
    locale: String,
    result: @escaping FlutterResult
  ) {
    guard FileManager.default.fileExists(atPath: path) else {
      result(FlutterError(
        code: "AUDIO_NOT_FOUND",
        message: "找不到录音文件",
        details: nil
      ))
      return
    }
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale)) else {
      result(FlutterError(
        code: "UNSUPPORTED_LOCALE",
        message: "设备不支持中文语音识别",
        details: locale
      ))
      return
    }
    guard recognizer.supportsOnDeviceRecognition else {
      result(FlutterError(
        code: "ON_DEVICE_SPEECH_UNAVAILABLE",
        message: "当前设备不支持离线中文语音识别",
        details: locale
      ))
      return
    }
    guard pendingResult == nil else {
      result(FlutterError(
        code: "RECOGNITION_BUSY",
        message: "已有语音识别任务正在运行",
        details: nil
      ))
      return
    }

    recognitionTask?.cancel()
    self.recognizer = recognizer
    pendingResult = result
    let request = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: path))
    request.requiresOnDeviceRecognition = true
    request.shouldReportPartialResults = false
    recognitionTask = recognizer.recognitionTask(with: request) { [weak self] response, error in
      DispatchQueue.main.async {
        guard let self, self.pendingResult != nil else { return }
        if let error {
          self.finish(FlutterError(
            code: "SPEECH_RECOGNITION_FAILED",
            message: "语音识别失败",
            details: error.localizedDescription
          ))
        } else if let response, response.isFinal {
          self.finish(response.bestTranscription.formattedString)
        }
      }
    }
  }

  private func finish(_ value: Any) {
    let result = pendingResult
    pendingResult = nil
    recognitionTask = nil
    recognizer = nil
    result?(value)
  }

  private func permissionError() -> FlutterError {
    FlutterError(
      code: "SPEECH_PERMISSION_DENIED",
      message: "没有语音识别权限，请在系统设置中允许语音识别",
      details: nil
    )
  }
}
