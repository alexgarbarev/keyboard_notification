import 'package:flutter/cupertino.dart';

import 'keyboard_notification_platform_interface.dart';

final _observers = <int, WeakReference<KeyboardObserver>>{};

abstract class KeyboardNotification {
  /// When [visible] is true, then keyboard animation is to show the keyboard,
  /// otherwise animation is to hide
  final bool visible;

  /// Keyboard height in logical pixels
  final double height;

  KeyboardNotification({required this.visible, required this.height});

  var _posted = false;
  void post() {
    assert(
      !_posted,
      'Same KeyboardAnimationNotification cannot be posted twice',
    );
    _posted = true;
    for (final observer in _observers.values) {
      observer.target?._post(this);
    }
  }
}

/// Posted right before keyboard animation is started
class KeyboardAnimationStartNotification extends KeyboardNotification {
  /// Animation duration to show/hide keyboard
  final Duration duration;

  /// Animation curve to sync UI with the keyboard appearance
  final Curve curve;

  /// If didFallback is true, then [duration] and [curve] values are guessed,
  /// as we are running on old Android API level and can't check exact ones
  final bool didFallback;

  KeyboardAnimationStartNotification({
    required super.visible,
    required super.height,
    required this.duration,
    required this.curve,
    this.didFallback = false,
  });

  @override
  String toString() {
    return 'KeyboardAnimationStartNotification(visible: $visible, height: $height, duration: $duration, curve: $curve, didFallback: $didFallback)';
  }
}

/// Posted once keyboard animation is finished
class KeyboardAnimationEndNotification extends KeyboardNotification {
  KeyboardAnimationEndNotification({
    required super.visible,
    required super.height,
  });

  @override
  String toString() {
    return 'KeyboardAnimationEndNotification(visible: $visible, height: $height)';
  }
}

typedef KeyboardNotificationListener = void Function(KeyboardNotification note);

class KeyboardObserver {
  bool initialized = false;
  final _listeners = <KeyboardNotificationListener>[];

  KeyboardObserver() {
    _observers[identityHashCode(this)] = WeakReference(this);
  }

  /// Specifies curve precision for Android, where curve is built using
  /// interpolator
  /// This method sets precision globally, so it would affect all
  /// KeyboardObservers (existing and in the future)
  void setCurvePrecision(double precision) {
    try {
      KeyboardNotificationPlatform.instance.setCurvePrecision(precision);
    } catch (e) {
      print('Unable to setCurvePrecision: $e');
    }
  }

  void addListener(KeyboardNotificationListener listener) {
    _listeners.add(listener);
    _initializeIfNeeded();
  }

  void removeListener(KeyboardNotificationListener listener) {
    _listeners.remove(listener);
  }

  void dispose() {
    _listeners.clear();
    _observers.remove(identityHashCode(this));
  }

  void _post(KeyboardNotification note) {
    for (final listener in _listeners) {
      listener(note);
    }
  }

  void _initializeIfNeeded() {
    KeyboardNotificationPlatform.instance;
  }
}
