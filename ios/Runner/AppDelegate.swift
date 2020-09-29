import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    SwiftBonsoirPlugin.register(with: self.registrar(forPlugin: "fr.skyost.bonsoir") as! FlutterPluginRegistrar)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
