import 'package:flutter/material.dart';
import 'package:keyboard_notification/keyboard_notification.dart';

class KeyboardAvoiding extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  const KeyboardAvoiding({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  State<KeyboardAvoiding> createState() => _KeyboardAvoidingState();
}

class _KeyboardAvoidingState extends State<KeyboardAvoiding> {
  final inheritedContextKey = UniqueKey();
  final observer = KeyboardObserver();

  @override
  void initState() {
    FocusManager.instance.addListener(_didChangePrimaryFocus);
    observer.addListener(onKeyboardNotification);
    super.initState();
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_didChangePrimaryFocus);
    observer.dispose();
    super.dispose();
  }

  void onKeyboardNotification(KeyboardNotification note) {
    print('Keyboard notification: $note');
    if (note is! KeyboardAnimationStartNotification) {
      // TODO: Check why we receiving notification with height < 100
      return;
    }

    // final parentBox = context.findRenderObject() as RenderBox?;
    // final focusedBox = focusedContext?.findRenderObject() as RenderBox?;
    // if (focusedBox == null || parentBox == null) {
    //   return;
    // }
    // final parentPosition = parentBox.localToGlobal(Offset.zero);
    // final focusedPosition = focusedBox.localToGlobal(Offset.zero);
    // final parentRect = Rect.fromLTWH(
    //   parentPosition.dx,
    //   parentPosition.dy,
    //   parentBox.size.width,
    //   parentBox.size.height,
    // );
    // var parentBottomAdjustment = 0.0;
    // // if (note is KeyboardAnimationStartNotification) {
    // parentBottomAdjustment = note.height * (note.visible ? -1 : 1);
    // // }
    //
    // final newParentRect = Rect.fromLTRB(
    //   parentRect.left,
    //   parentRect.top,
    //   parentRect.right,
    //   parentRect.bottom + parentBottomAdjustment,
    // );
    //
    // widget.strategy.update(
    //   parent: newParentRect,
    //   focusedChild: Rect.fromLTWH(
    //     focusedPosition.dx,
    //     focusedPosition.dy,
    //     focusedBox.size.width,
    //     focusedBox.size.height,
    //   ),
    //   curve: note.curve,
    //   duration: note.duration,
    // );
  }

  void _didChangePrimaryFocus() {
    final focused = FocusManager.instance.primaryFocus;
    final focusedContext = focused?.context;
    // if (focusedContext != null) {
    //   if (_isInsideCurrentWidget(focused)) {
    //     this.focusedContext = focusedContext;
    //   } else {
    //     this.focusedContext = null;
    //   }
    //   // logs.v('Primary focus node inside KeyboardAvoiding: $isInside');
    // } else {
    //   this.focusedContext = null;
    // }
  }

  bool _isInsideCurrentWidget(FocusNode? node) {
    final inherited =
        node?.context
            ?.getInheritedWidgetOfExactType<
              _KeyboardAvoidingInheritedContext
            >();
    return inherited != null && inherited.key == inheritedContextKey;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (note) {
        if (note is SizeChangedLayoutNotification) {
          print(
            'Flutter notification: ${note}, self size: ${context.size}, ${widget.scrollController.position.maxScrollExtent}',
          );
        }
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: _KeyboardAvoidingInheritedContext(
          key: inheritedContextKey,
          child: widget.child,
        ),
      ),
    );
  }
}

class _KeyboardAvoidingInheritedContext extends InheritedWidget {
  const _KeyboardAvoidingInheritedContext({super.key, required super.child});

  @override
  bool updateShouldNotify(_KeyboardAvoidingInheritedContext oldWidget) {
    return oldWidget.key != key;
  }
}
