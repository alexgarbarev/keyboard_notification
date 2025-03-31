import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_notification/keyboard_notification.dart';
import 'package:keyboard_notification/keyboard_notification_method_channel.dart';
import 'package:keyboard_notification/keyboard_notification_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKeyboardNotificationPlatform
    with MockPlatformInterfaceMixin
    implements KeyboardNotificationPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final KeyboardNotificationPlatform initialPlatform =
      KeyboardNotificationPlatform.instance;

  test('$MethodChannelKeyboardNotification is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKeyboardNotification>());
  });

  test('getPlatformVersion', () async {
    final keyboardNotificationPlugin = KeyboardNotification();
    MockKeyboardNotificationPlatform fakePlatform =
        MockKeyboardNotificationPlatform();
    KeyboardNotificationPlatform.instance = fakePlatform;

    expect(await keyboardNotificationPlugin.getPlatformVersion(), '42');
  });
}
