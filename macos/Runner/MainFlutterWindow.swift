import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    var windowFrame = self.frame
    if windowFrame.width == 0 || windowFrame.height == 0 {
        windowFrame = NSMakeRect(0, 0, 1280, 720)
    }
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.makeKeyAndOrderFront(nil)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
