import 'package:flutter/material.dart';

class TrimeSpacing {
  TrimeSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardInnerPadding = EdgeInsets.all(sm);

  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(20.0));
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(999.0));

  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(20.0),
  );

  static const double elevationCard = 2.0;
  static const double elevationButton = 1.0;
  static const double elevationPressed = 4.0;
  static const double elevationNav = 8.0;
}
