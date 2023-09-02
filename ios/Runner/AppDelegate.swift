import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      let _controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      ScreenOrientationPlugin.shareInstance().register(withRegistry:  _controller.binaryMessenger)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
