// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_notification/keyboard_tester.dart';
import 'package:keyboard_notification_example/main.dart';

void main() {
  testWidgets('Verify keyboard visibility changes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleAnimations());

    tester.setKeyboardVisible(true);
    await tester.pumpAndSettle();

    var visibilitySemantics = find.byWidgetPredicate(
      (widget) => widget is Text && widget.semanticsLabel == 'visibility',
    );

    expect(visibilitySemantics, findsOneWidget);
    expect(
      tester.widget<Text>(visibilitySemantics).data,
      contains('visibility: 1.0'),
    );

    tester.setKeyboardVisible(false);
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(visibilitySemantics).data,
      contains('visibility: 0.0'),
    );
  });
}
