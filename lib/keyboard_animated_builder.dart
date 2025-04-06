import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:keyboard_notification/keyboard_notification.dart';

enum KeyboardAnimationState {
  none,
  opening,
  closing;

  @override
  String toString() {
    switch (this) {
      case KeyboardAnimationState.none:
        return 'none';
      case KeyboardAnimationState.opening:
        return 'opening';
      case KeyboardAnimationState.closing:
        return 'closing';
    }
  }
}

class KeyboardState {
  final KeyboardAnimationState animationState;

  /// Current portion of keyboard which is visible. Changes between 0 to 1 during animation
  final double visibility;

  /// Current height of the keyboard - it changes every frame during animation
  final double height;

  /// Total height of the keyboard
  final double totalHeight;
  KeyboardState({
    required this.animationState,
    required this.visibility,
    required this.height,
    required this.totalHeight,
  });

  double get animation {
    switch (animationState) {
      case KeyboardAnimationState.none:
        return 1.0;
      case KeyboardAnimationState.opening:
        return visibility;
      case KeyboardAnimationState.closing:
        return 1.0 - visibility;
    }
  }

  bool get isOpened =>
      animationState == KeyboardAnimationState.none && visibility == 1.0;
  bool get isClosed =>
      animationState == KeyboardAnimationState.none && visibility == 0.0;
  bool get isAnimating => animationState != KeyboardAnimationState.none;

  @override
  String toString() {
    final buffer = StringBuffer('KeyboardState(animation: ');
    if (animationState != KeyboardAnimationState.none) {
      buffer.write('$animationState: ${(animation * 100).round()}%, ');
    } else {
      buffer.write('$animationState, ');
    }
    buffer.write(
      'height: ${height.toStringAsFixed(2)}/${totalHeight.toStringAsFixed(2)}, ',
    );
    buffer.write('visibility: ${visibility.toStringAsFixed(3)}');
    buffer.write(')');
    return buffer.toString();
  }
}

class KeyboardAnimatedBuilder extends StatefulWidget {
  final void Function(KeyboardState keyboard)? onChange;
  final Widget Function(
    BuildContext context,
    KeyboardState keyboard,
    Widget? child,
  )?
  builder;
  final Widget? child;
  const KeyboardAnimatedBuilder({
    super.key,
    this.builder,
    this.child,
    this.onChange,
  });

  @override
  State<KeyboardAnimatedBuilder> createState() =>
      _KeyboardAnimatedBuilderState();
}

class _KeyboardAnimatedBuilderState extends State<KeyboardAnimatedBuilder>
    with WidgetsBindingObserver {
  final observer = KeyboardObserver();
  KeyboardState? keyboard;
  KeyboardAnimationStartNotification? keyboardStartNote;

  @override
  void initState() {
    observer.addListener(_onKeyboardNotification);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    observer.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (keyboardStartNote != null || kIsWeb || keyboard?.isOpened == true) {
      _updateKeyboardState(() {
        keyboard = _getKeyboardState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.builder != null || widget.child != null,
      'Either builder or child must be provided',
    );
    final builder = widget.builder;
    if (builder == null) {
      return widget.child!;
    }
    keyboard ??= _getKeyboardState();
    return builder(context, keyboard!, widget.child);
  }

  void _onKeyboardNotification(KeyboardNotification note) {
    if (note is KeyboardAnimationStartNotification) {
      _updateKeyboardState(() {
        keyboardStartNote = note;
        keyboard = _getKeyboardState();
      });
    } else if (note is KeyboardAnimationEndNotification) {
      _updateKeyboardState(() {
        keyboardStartNote = null;
        final isOpened =
            keyboard!.animationState == KeyboardAnimationState.opening;
        keyboard = KeyboardState(
          animationState: KeyboardAnimationState.none,
          visibility: isOpened ? 1.0 : 0.0,
          height: isOpened ? keyboard!.totalHeight : 0.0,
          totalHeight: keyboard!.totalHeight,
        );
      });
    }
  }

  KeyboardState _getKeyboardState() {
    final view = View.of(context);

    if (keyboardStartNote != null) {
      final totalHeight = keyboardStartNote!.height;
      final height = view.viewInsets.bottom / view.devicePixelRatio;
      final visibility = (height / totalHeight).clamp(0.0, 1.0);
      final state =
          keyboardStartNote!.visible
              ? KeyboardAnimationState.opening
              : KeyboardAnimationState.closing;
      return KeyboardState(
        animationState: state,
        visibility: visibility,
        height: height,
        totalHeight: totalHeight,
      );
    }

    final remainingHeight = view.physicalSize.height - view.viewInsets.bottom;
    if (remainingHeight / view.physicalSize.height < 0.85) {
      return KeyboardState(
        animationState: KeyboardAnimationState.none,
        visibility: 1.0,
        height: view.viewInsets.bottom / view.devicePixelRatio,
        totalHeight: view.viewInsets.bottom / view.devicePixelRatio,
      );
    } else {
      return KeyboardState(
        animationState: KeyboardAnimationState.none,
        visibility: 0.0,
        height: 0,
        totalHeight: 0,
      );
    }
  }

  void _updateKeyboardState(void Function() callback) {
    if (widget.builder != null) {
      setState(callback);
    } else {
      callback();
    }
    widget.onChange?.call(keyboard!);
  }
}
