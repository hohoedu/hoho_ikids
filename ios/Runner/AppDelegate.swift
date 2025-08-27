import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    var orientationLock = UIInterfaceOrientationMask.landscape

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let orientationChannel = FlutterMethodChannel(name: "orientation", binaryMessenger: controller.binaryMessenger)

        orientationChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            if call.method == "setPortrait" {
                self.orientationLock = .portrait
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UINavigationController.attemptRotationToDeviceOrientation()
                result(nil)
            } else if call.method == "setLandscape" {
                self.orientationLock = .landscape
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                UINavigationController.attemptRotationToDeviceOrientation()
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
}
