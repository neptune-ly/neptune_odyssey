import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    // Fixed phone-ish frame so the gallery reads like the web templates
    // (and screenshots are repeatable).
    let frame = NSRect(x: 700, y: 42, width: 480, height: 900)
    self.contentViewController = flutterViewController
    self.setFrame(frame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
