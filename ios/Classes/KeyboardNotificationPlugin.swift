import Flutter
import UIKit

public class KeyboardNotificationPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "keyboard_notification", binaryMessenger: registrar.messenger())
        let instance = KeyboardNotificationPlugin()
        instance.channel = channel;
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    var channel: FlutterMethodChannel!;
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardNotificationPlugin.onKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardNotificationPlugin.onKeyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardNotificationPlugin.onKeyboardNotification(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardNotificationPlugin.onKeyboardNotification(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        
    }
    
    @objc
    func onKeyboardNotification(_ notification: Notification) {
        let bottomInsets = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        let bounds = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect ?? .zero
    

        
        if (notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillHideNotification) {
            let duration = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? TimeInterval ?? 0
            let curve = notification.userInfo?["UIKeyboardAnimationCurveUserInfoKey"] as? Int ?? 0
            
//            let options = UIView.AnimationOptions(rawValue: UInt(curve) << 16)
//            let ccc = UIView.AnimationCurve(rawValue: curve)
            
//            print("Animation options: \(options), \(UIView.AnimationOptions.curveEaseInOut), \(ccc.)")
            
            channel.invokeMethod("keyboard_notification_animation_start", arguments: [
                "height": bounds.height,
                "overlapHeight": bounds.height - bottomInsets,
                "visible": notification.name == UIResponder.keyboardWillShowNotification,
                "duration": Int(duration * 1000),
                "curveType": curve
            ])
        } else {
            channel.invokeMethod("keyboard_notification_animation_end", arguments: [
                "height": bounds.height,
                "overlapHeight": bounds.height - bottomInsets,
                "visible": notification.name == UIResponder.keyboardDidShowNotification
            ])
        }
        
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
