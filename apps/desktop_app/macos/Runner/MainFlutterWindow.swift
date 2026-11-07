import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let channel = FlutterMethodChannel(name: "net_keyboard/input",
        binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { call, result in
      MacInput.handle(call, result: result)
    }
    super.awakeFromNib()
  }
}

// Quartz events are posted only after explicit macOS Accessibility consent.
private enum MacInput {
  static let keys: [String: CGKeyCode] = [
    "keyA":0, "keyS":1, "keyD":2, "keyF":3, "keyH":4, "keyG":5,
    "keyZ":6, "keyX":7, "keyC":8, "keyV":9, "keyB":11,
    "keyQ":12, "keyW":13, "keyE":14, "keyR":15, "keyY":16, "keyT":17,
    "digit1":18, "digit2":19, "digit3":20, "digit4":21, "digit6":22,
    "digit5":23, "equal":24, "digit9":25, "digit7":26, "minus":27,
    "digit8":28, "digit0":29, "bracketRight":30, "keyO":31, "keyU":32,
    "bracketLeft":33, "keyI":34, "keyP":35, "enter":36, "keyL":37,
    "keyJ":38, "quote":39, "keyK":40, "semicolon":41, "backslash":42,
    "comma":43, "slash":44, "keyN":45, "keyM":46, "period":47,
    "tab":48, "space":49, "backquote":50, "backspace":51, "escape":53,
    "capsLock":57, "f1":122, "f2":120, "f3":99, "f4":118, "f5":96,
    "f6":97, "f7":98, "f8":100, "f9":101, "f10":109, "f11":103,
    "f12":111, "home":115, "pageUp":116, "delete":117, "end":119,
    "pageDown":121, "arrowLeft":123, "arrowRight":124,
    "arrowDown":125, "arrowUp":126,
  ]
  // Wire modifier order: L/R Control, Option, Shift, Command.
  static let modifiers: [(CGKeyCode, CGEventFlags)] = [
    (59, .maskControl), (62, .maskControl), (58, .maskAlternate),
    (61, .maskAlternate), (56, .maskShift), (60, .maskShift),
    (55, .maskCommand), (54, .maskCommand),
  ]
  static var lastClick: (String, CFAbsoluteTime, CGPoint)?

  static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    if call.method == "isTrusted" {
      let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String:
                     args["prompt"] as? Bool ?? false] as CFDictionary
      result(AXIsProcessTrustedWithOptions(options))
      return
    }
    guard AXIsProcessTrusted() else {
      result(FlutterError(code: "INPUT_BLOCKED", message:
        "请在系统设置 → 隐私与安全性 → 辅助功能中授权网络键鼠受控端", details: nil))
      return
    }
    // Build every event before posting, so allocation failures cannot leave a modifier down.
    var events: [CGEvent] = []
    var cursorWarp: CGPoint?
    func key(_ code: CGKeyCode, _ down: Bool, _ flags: CGEventFlags) throws {
      guard let event = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: down)
      else { throw InputError.allocation }
      if modifiers.contains(where: { $0.0 == code }) || code == 57 {
        event.type = .flagsChanged
      }
      event.flags = flags
      events.append(event)
    }
    do {
      switch call.method {
      case "keyStroke":
        let name = args["key"] as? String ?? ""
        let bits = args["modifiers"] as? Int ?? 0
        guard bits >= 0 && bits & ~255 == 0 else { throw InputError.unsupported }
        // PrintScreen uses the macOS screenshot shortcut; Menu uses Shift+F10.
        let code: CGKeyCode
        var selected = modifiers.enumerated().filter { bits & (1 << $0.offset) != 0 }
          .map { $0.element }
        if name == "printScreen" {
          code = 20
          selected = [(55, .maskCommand), (56, .maskShift)]
        } else if name == "menu" {
          code = 109
          selected = [(56, .maskShift)]
        } else if let mapped = keys[name] { code = mapped }
        else { throw InputError.unsupported }
        let lockFlags = CGEventSource.flagsState(.combinedSessionState)
          .intersection(.maskAlphaShift)
        var flags = lockFlags
        for (modifier, flag) in selected {
          flags.insert(flag)
          try key(modifier, true, flags)
        }
        if name == "capsLock" {
          if flags.contains(.maskAlphaShift) { flags.remove(.maskAlphaShift) }
          else { flags.insert(.maskAlphaShift) }
        }
        try key(code, true, flags)
        try key(code, false, flags)
        for index in selected.indices.reversed() {
          flags = selected[..<index].reduce(lockFlags) { $0.union($1.1) }
          try key(selected[index].0, false, flags)
        }
      case "text":
        guard NSWorkspace.shared.frontmostApplication != nil else {
          result(FlutterError(code: "NO_FOREGROUND_TARGET",
            message: "NO_FOREGROUND_TARGET", details: nil)); return
        }
        let text = args["text"] as? String ?? ""
        guard !text.isEmpty && text.utf16.count <= 8192 && !text.contains("\0")
        else { throw InputError.unsupported }
        // One Unicode scalar per pair preserves surrogate pairs without oversized events.
        for scalar in text.unicodeScalars {
          let units = Array(String(scalar).utf16)
          for down in [true, false] {
            try key(0, down, [])
            units.withUnsafeBufferPointer {
              events.last!.keyboardSetUnicodeString(stringLength: $0.count, unicodeString: $0.baseAddress)
            }
          }
        }
      case "pointer":
        let old = quartzMouseLocation()
        let dx = max(-4096, min(4096, args["deltaX"] as? Int ?? 0))
        let dy = max(-4096, min(4096, args["deltaY"] as? Int ?? 0))
        var point = CGPoint(x: old.x + CGFloat(dx), y: old.y + CGFloat(dy))
        // Keep the cursor within an actual display, including multi-monitor layouts.
        let displays = NSScreen.screens.map { screen -> CGRect in
          let mainHeight = NSScreen.screens.first?.frame.height ?? 0
          return CGRect(x: screen.frame.minX, y: mainHeight - screen.frame.maxY,
                        width: screen.frame.width, height: screen.frame.height)
        }
        if !displays.contains(where: { $0.contains(point) }),
           let nearest = displays.min(by: { distance(point, $0) < distance(point, $1) }) {
          point.x = max(nearest.minX, min(nearest.maxX - 1, point.x))
          point.y = max(nearest.minY, min(nearest.maxY - 1, point.y))
        }
        if dx != 0 || dy != 0 {
          guard let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                                    mouseCursorPosition: point, mouseButton: .left)
          else { throw InputError.allocation }
          event.setIntegerValueField(.mouseEventDeltaX, value: Int64(dx))
          event.setIntegerValueField(.mouseEventDeltaY, value: Int64(dy))
          cursorWarp = point
          events.append(event)
        }
        let button = args["button"] as? String ?? "none"
        if button != "none" {
          let down = args["buttonDown"] as? Bool ?? false
          let type: CGEventType
          let native: CGMouseButton
          switch button {
          case "left": native = .left; type = down ? .leftMouseDown : .leftMouseUp
          case "right": native = .right; type = down ? .rightMouseDown : .rightMouseUp
          case "middle": native = .center; type = down ? .otherMouseDown : .otherMouseUp
          default: throw InputError.unsupported
          }
          guard let event = CGEvent(mouseEventSource: nil, mouseType: type,
                                    mouseCursorPosition: point, mouseButton: native)
          else { throw InputError.allocation }
          let now = CFAbsoluteTimeGetCurrent()
          var clicks = 1
          if let previous = lastClick, previous.0 == button,
             now - previous.1 <= NSEvent.doubleClickInterval,
             hypot(previous.2.x - point.x, previous.2.y - point.y) < 5 { clicks = 2 }
          if down { lastClick = (button, clicks == 2 ? 0 : now, point) }
          // Up events must carry the same click count as the matching down.
          if down { clickCount = clicks }
          event.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))
          events.append(event)
        }
        let vertical = max(-1200, min(1200, args["wheelDelta"] as? Int ?? 0))
        let horizontal = max(-1200, min(1200, args["horizontalWheelDelta"] as? Int ?? 0))
        if vertical != 0 || horizontal != 0 {
          guard let event = CGEvent(scrollWheelEvent2Source: nil, units: .pixel,
            wheelCount: 2, wheel1: Int32(vertical), wheel2: Int32(-horizontal), wheel3: 0)
          else { throw InputError.allocation }
          events.append(event)
        }
      default: result(FlutterMethodNotImplemented); return
      }
      if let point = cursorWarp {
        let error = CGWarpMouseCursorPosition(point)
        guard error == .success else { throw InputError.cursorMove(error) }
      }
      for event in events { event.post(tap: .cghidEventTap) }
      result(events.count)
    } catch {
      result(FlutterError(code: "INPUT_BLOCKED", message: "无法创建输入事件：\(error)", details: nil))
    }
  }
  static var clickCount = 1
  static func quartzMouseLocation() -> CGPoint {
    let cocoaPoint = NSEvent.mouseLocation
    let mainDisplayBounds = CGDisplayBounds(CGMainDisplayID())
    return CGPoint(
      x: cocoaPoint.x,
      y: mainDisplayBounds.height - cocoaPoint.y
    )
  }
  static func distance(_ p: CGPoint, _ r: CGRect) -> CGFloat {
    hypot(p.x - max(r.minX, min(r.maxX, p.x)), p.y - max(r.minY, min(r.maxY, p.y)))
  }
  enum InputError: Error {
    case allocation, unsupported
    case cursorMove(CGError)
  }
}
