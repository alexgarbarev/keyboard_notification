import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'keyboard_notification.dart';
import 'keyboard_notification_platform_interface.dart';

/// An implementation of [KeyboardNotificationPlatform] that uses method channels.
class MethodChannelKeyboardNotification extends KeyboardNotificationPlatform {
  void Function(KeyboardNotification note)? onNote;

  MethodChannelKeyboardNotification() {
    methodChannel.setMethodCallHandler(_methodHandler);
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('keyboard_notification');

  Future<dynamic> _methodHandler(MethodCall call) async {
    switch (call.method) {
      case 'keyboard_notification_animation_start':
        {
          KeyboardAnimationStartNotification(
            visible: call.arguments['visible'] as bool,
            height: call.arguments['height'] as double,
          ).post();
        }
      case 'keyboard_notification_animation_end':
        {
          KeyboardAnimationEndNotification(
            visible: call.arguments['visible'] as bool,
            height: call.arguments['height'] as double,
          ).post();
        }
      case 'keyboard_notification_toggle':
        {
          _simulateAnimationNotification(
            visible: call.arguments['visible'] as bool,
            height: call.arguments['height'] as double,
          );
        }
      default:
        throw Exception('Unexpected method call ${call.method}');
    }
  }

  Future<void> _simulateAnimationNotification({
    required bool visible,
    required double height,
  }) async {
    KeyboardAnimationStartNotification(visible: visible, height: height).post();
    await Future.delayed(Duration(milliseconds: 300));
    KeyboardAnimationEndNotification(visible: visible, height: height).post();
  }
}
