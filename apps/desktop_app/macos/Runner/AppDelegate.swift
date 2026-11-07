import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var instanceLock: Int32 = -1
  private let wakeName = Notification.Name("com.netkeyboard.controlled-device.show")

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let directory = FileManager.default.urls(for: .applicationSupportDirectory,
                                             in: .userDomainMask)[0]
      .appendingPathComponent("com.netkeyboard.netKeyboardDesktop")
    do {
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      instanceLock = open(directory.appendingPathComponent("controlled-device.lock").path,
                          O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
      guard instanceLock >= 0 else { NSApp.terminate(nil); return }
      if flock(instanceLock, LOCK_EX | LOCK_NB) != 0 {
        DistributedNotificationCenter.default().postNotificationName(
          wakeName, object: nil, userInfo: nil, deliverImmediately: true)
        NSApp.terminate(nil)
        return
      }
      DistributedNotificationCenter.default().addObserver(self,
        selector: #selector(showControlledDevice), name: wakeName, object: nil)
    } catch { NSApp.terminate(nil); return }
    super.applicationDidFinishLaunching(notification)
  }

  @objc private func showControlledDevice() {
    DispatchQueue.main.async {
      self.mainFlutterWindow?.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    }
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication,
      hasVisibleWindows flag: Bool) -> Bool {
    showControlledDevice()
    return true
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
