import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Desktop window chrome: a comfortable default and a sane minimum so the
    // responsive shell always has room for the side nav + content.
    self.title = "Neptune Odyssey"
    self.minSize = NSSize(width: 1040, height: 720)
    self.setContentSize(NSSize(width: 1320, height: 860))
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
