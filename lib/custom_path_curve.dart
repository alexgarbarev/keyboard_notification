import 'package:flutter/animation.dart';

class CustomPathCurve extends Curve {
  final List<double> _mX;
  final List<double> _mY;
  CustomPathCurve(this._mX, this._mY) {
    assert(_mX.length == _mY.length);
  }

  factory CustomPathCurve.withPoints({
    required List<double> points,
    required double precision,
  }) {
    var x = 0.0;
    final mX = <double>[];
    while (x <= 1.0) {
      mX.add(x);
      x += precision;
    }
    return CustomPathCurve(mX, points);
  }

  // This code was translated from PathInterpolator.java, to match Android implementation
  @override
  double transformInternal(double t) {
    if (t <= 0) {
      return 0;
    } else if (t >= 1) {
      return 1;
    }
    // Do a binary search for the correct x to interpolate between.
    int startIndex = 0;
    int endIndex = _mX.length - 1;

    while (endIndex - startIndex > 1) {
      int midIndex = (startIndex + endIndex) ~/ 2;
      if (t < _mX[midIndex]) {
        endIndex = midIndex;
      } else {
        startIndex = midIndex;
      }
    }

    final xRange = _mX[endIndex] - _mX[startIndex];
    if (xRange == 0) {
      return _mY[startIndex];
    }

    final tInRange = t - _mX[startIndex];
    final fraction = tInRange / xRange;

    final startY = _mY[startIndex];
    final endY = _mY[endIndex];
    return startY + (fraction * (endY - startY));
  }
}
