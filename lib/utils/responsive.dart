import 'package:flutter/material.dart';

extension ResponsiveUtils on BuildContext {
  /// The width of the screen.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// The height of the screen.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns a width calculated from a percentage of the screen width.
  double wp(double percent) => screenWidth * percent / 100;

  /// Returns a height calculated from a percentage of the screen height.
  double hp(double percent) => screenHeight * percent / 100;

  /// Returns a scaled font size based on the screen width.
  /// Calculated relative to a standard design width of 375 pixels.
  double sp(double fontSize) {
    double scaleFactor = screenWidth / 375;

    // Clamp the scale factor to prevent fonts from becoming overly large on tablets
    // while still allowing them to grow appropriately for larger phones.
    if (scaleFactor > 1.25) scaleFactor = 1.25;
    if (scaleFactor < 0.85) scaleFactor = 0.85;

    return fontSize * scaleFactor;
  }

  /// Helper to check if the screen is considered "small" (e.g., older SE models).
  bool get isSmallScreen => screenHeight < 700;

  /// Helper to check if the device is a tablet.
  bool get isTablet => screenWidth > 600;
}
