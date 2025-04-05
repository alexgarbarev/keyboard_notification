import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'keyboard_notification_method_channel.dart';

abstract class KeyboardNotificationPlatform extends PlatformInterface {
  /// Constructs a KeyboardNotificationPlatform.
  KeyboardNotificationPlatform() : super(token: _token);

  static final Object _token = Object();

  static KeyboardNotificationPlatform _instance =
      MethodChannelKeyboardNotification();

  /// The default instance of [KeyboardNotificationPlatform] to use.
  ///
  /// Defaults to [MethodChannelKeyboardNotification].
  static KeyboardNotificationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KeyboardNotificationPlatform] when
  /// they register themselves.
  static set instance(KeyboardNotificationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
