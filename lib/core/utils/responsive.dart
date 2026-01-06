import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQuery;
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _scaleWidth;
  static late double _scaleHeight;
  static late double _textScale;

  static void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
    _screenWidth = _mediaQuery.size.width;
    _screenHeight = _mediaQuery.size.height;

    // Base mobile design size
    _scaleWidth = _screenWidth / 375;
    _scaleHeight = _screenHeight / 812;

    _textScale = _scaleWidth.clamp(0.85, 1.15);
  }

  /// Width responsive
  static double w(double width) => width * _scaleWidth;

  /// Height responsive
  static double h(double height) => height * _scaleHeight;

  /// Font responsive
  static double sp(double fontSize) => fontSize * _textScale;

  /// Radius responsive
  static double r(double radius) => radius * _scaleWidth;
}
