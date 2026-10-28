import 'package:flutter/material.dart';

/// Spacing tokens.
class Spacing {
  Spacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Radius tokens.
class Radii {
  Radii._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xl = 20;
  static const double xxl = 28;

  static const BorderRadius rSmall = BorderRadius.all(Radius.circular(small));
  static const BorderRadius rMedium = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius rLarge = BorderRadius.all(Radius.circular(large));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius rXxl = BorderRadius.all(Radius.circular(xxl));
}

/// Icon size tokens.
class IconSize {
  IconSize._();

  static const double small = 16;
  static const double medium = 20;
  static const double large = 24;
  static const double xl = 28;
}

/// Minimum tap target size.
const double kMinTapTarget = 44.0;
