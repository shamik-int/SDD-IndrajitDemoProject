import 'package:flutter/material.dart';

/// Palette proposed in ADR-0001 §6. Treat as a Gate-1-confirmable default,
/// not a final design-system token set — swap here if the actual One-Point
/// Portal design system disagrees.
class AppColors {
  AppColors._();

  // Primary — Green
  static const primaryLight = Color(0xFF2E7D32);
  static const primaryVariantLight = Color(0xFF1B5E20);
  static const primaryDark = Color(0xFF66BB6A);
  static const primaryVariantDark = Color(0xFF388E3C);

  // Accent — Yellow
  static const accentLight = Color(0xFFFBC02D);
  static const accentDark = Color(0xFFFFD54F);

  // Secondary tint shades
  static const secondaryTintGreenLight = Color(0xFFE8F5E9);
  static const secondaryTintGreenDark = Color(0xFF1B3A1D);
  static const secondaryTintYellowLight = Color(0xFFFFF9C4);
  static const secondaryTintYellowDark = Color(0xFF3A3319);

  // Surfaces
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF121212);

  // Text shades
  static const textPrimaryLight = Color(0xFF212121);
  static const textSecondaryLight = Color(0xFF616161);
  static const textDisabledLight = Color(0xFF9E9E9E);

  static const textPrimaryDark = Color(0xFFF5F5F5);
  static const textSecondaryDark = Color(0xFFBDBDBD);
  static const textDisabledDark = Color(0xFF6E6E6E);
}
