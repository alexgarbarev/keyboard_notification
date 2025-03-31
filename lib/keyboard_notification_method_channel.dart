import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_notification/custom_path_curve.dart';

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

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  void setCurvePrecision(double precision) {
    try {
      methodChannel.invokeMethod('setCurvePrecision', {'value': precision});
    } catch (e) {
      print('Unable to set curve precision: ${e}');
    }
  }

  Future<dynamic> _methodHandler(MethodCall call) async {
    // print('Call: ${call.method}');
    switch (call.method) {
      case 'keyboard_notification_animation_start':
        {
          final visible = call.arguments['visible'] as bool;
          final precision = call.arguments['precision'] as double?;
          final curveType = call.arguments['curveType'] as int?;
          Curve? curve;
          if (precision != null) {
            final points = call.arguments['curvePoints'] as List<Object?>;
            curve = CustomPathCurve.withPoints(
              points: points.cast<double>(),
              precision: precision,
            );
          } else if (curveType != null) {
            switch (curveType) {
              case 0:
                curve = Curves.easeInOut;
              case 1:
                curve = Curves.easeIn;
              case 2:
                curve = Curves.easeOut;
              case 3:
                curve = Curves.linear;
              default:
                curve = Curves.decelerate;
            }
          } else {
            curve = Curves.linear;
          }

          KeyboardAnimationStartNotification(
            visible: call.arguments['visible'] as bool,
            height: call.arguments['height'] as double,
            overlapHeight: call.arguments['overlapHeight'] as double,
            duration: Duration(milliseconds: call.arguments['duration'] as int),
            curve: curve,
          ).post();
        }
      case 'keyboard_notification_animation_end':
        {
          KeyboardAnimationEndNotification(
            visible: call.arguments['visible'] as bool,
            height: call.arguments['height'] as double,
            overlapHeight: call.arguments['overlapHeight'] as double,
          ).post();
        }
      case 'keyboard_notification_toggle':
        {
          _simulateAnimationNotification(
            visible: call.arguments['visible'] as bool,
            height: call.arguments['height'] as double,
            overlapHeight: call.arguments['overlapHeight'] as double,
          );
        }
      default:
        print('Unexpected method call ${call.method}');
    }
  }

  Future<void> _simulateAnimationNotification({
    required bool visible,
    required double height,
    required double overlapHeight,
  }) async {
    KeyboardAnimationStartNotification(
      visible: visible,
      height: height,
      overlapHeight: overlapHeight,
      duration: Duration(milliseconds: 300),
      curve: Curves.linear,
      didFallback: true,
    ).post();
    await Future.delayed(Duration(milliseconds: 300));
    KeyboardAnimationEndNotification(
      visible: visible,
      overlapHeight: overlapHeight,
      height: height,
    ).post();
  }
}
