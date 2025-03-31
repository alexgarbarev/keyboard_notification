import 'package:flutter/widgets.dart';
import 'package:keyboard_notification/keyboard_notification.dart';

abstract class KeyboardAnimationDetails {
  double get progress;
  double get height;
}

class KeyboardAnimationDetailsAnimated implements KeyboardAnimationDetails {
  final AnimationController _controller;
  final Animation<double> progressAnimation;
  final Animation<double> heightAnimation;
  final bool isOpening;
  KeyboardAnimationDetailsAnimated(
    this._controller, {
    required this.progressAnimation,
    required this.heightAnimation,
    required this.isOpening,
  });

  double get progress => progressAnimation.value;
  double get height => heightAnimation.value;

  @override
  String toString() {
    return 'KeyboardAnimationDetails(progress: $progress, height: $height)';
  }

  void _dispose() {
    _controller.dispose();
  }
}

class KeyboardState {}

class KeyboardAnimationBuilder extends StatefulWidget {
  final void Function(KeyboardAnimationDetails? animation)? onChange;
  final Widget Function(
    BuildContext context,
    KeyboardAnimationDetails? animation,
    Widget? child,
  )?
  builder;
  final Widget? child;
  const KeyboardAnimationBuilder({
    super.key,
    this.builder,
    this.child,
    this.onChange,
  });

  @override
  State<KeyboardAnimationBuilder> createState() =>
      _KeyboardAnimationBuilderState();
}

class _KeyboardAnimationBuilderState extends State<KeyboardAnimationBuilder>
    with TickerProviderStateMixin {
  final observer = KeyboardObserver();
  KeyboardAnimationDetailsAnimated? currentAnimation;

  @override
  void initState() {
    // print('Created ${identityHashCode(this)}');
    observer.addListener(onKeyboardNotification);
    super.initState();
  }

  @override
  void dispose() {
    // print('disposed ${identityHashCode(this)}');
    observer.dispose();
    currentAnimation?._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.builder != null || widget.child != null,
      'Either builder or child must be provided',
    );
    // print('${identityHashCode(this)} rebuild');
    final builder = widget.builder;
    if (builder == null) {
      return widget.child!;
    }
    final current = currentAnimation;
    if (current != null) {
      return AnimatedBuilder(
        animation: current._controller,
        builder: (context, _) => builder(context, current, widget.child),
      );
    } else {
      return builder(context, null, widget.child);
    }
  }

  void onAnimationChange() {
    // print('on change');
    widget.onChange?.call(currentAnimation);
  }

  void onKeyboardNotification(KeyboardNotification note) {
    if (note is KeyboardAnimationStartNotification) {
      final animationController = AnimationController(
        vsync: this,
        duration: note.duration,
      );
      final curved = CurvedAnimation(
        parent: animationController,
        curve: note.curve,
      );
      final progressAnimation = Tween(begin: 0.0, end: 1.0).animate(curved);
      final heightAnimation = Tween(
        end: note.visible ? note.overlapHeight : 0.0,
        begin: note.visible ? 0.0 : note.overlapHeight,
      ).animate(curved);
      animationController.addListener(onAnimationChange);

      setState(() {
        currentAnimation?._dispose();
        currentAnimation = KeyboardAnimationDetailsAnimated(
          animationController,
          heightAnimation: heightAnimation,
          progressAnimation: progressAnimation,
          isOpening: note.visible,
        );
      });
      animationController.forward();
    } else if (note is KeyboardAnimationEndNotification) {
      setState(() {
        currentAnimation?._dispose();
        currentAnimation = null;
      });
    }
  }
}
