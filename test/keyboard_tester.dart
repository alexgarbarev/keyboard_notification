import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_notification/keyboard_notification.dart';

extension KeyboardTester on WidgetTester {
  void setKeyboardVisible(bool visible, {double? height}) {
    double keyboardHeight = height ?? (view.physicalSize.height * 0.4);
    KeyboardAnimationStartNotification(
      visible: visible,
      height: keyboardHeight,
    ).post();
    view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
    KeyboardAnimationEndNotification(
      visible: visible,
      height: keyboardHeight,
    ).post();
  }
}
