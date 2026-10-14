import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  // Durations
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration cardTransition = Duration(milliseconds: 280);
  static const Duration screenTransition = Duration(milliseconds: 350);
  static const Duration modal = Duration(milliseconds: 300);
  static const Duration staggerStep = Duration(milliseconds: 60);

  // Curves
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve stateChangeCurve = Curves.easeInOutCubic;
}
