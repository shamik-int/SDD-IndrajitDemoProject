import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Font is Lato, self-hosted under assets/fonts/ (ADR-0001 §6). The family
/// name below matches the `fonts:` entry to uncomment in pubspec.yaml once
/// the real .ttf files are added.
class AppTextStyles {
  AppTextStyles._();

  static const _fontFamily = 'Lato';

  static TextTheme light = TextTheme(
    titleLarge: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 22,
      color: AppColors.textPrimaryLight,
    ),
    titleMedium: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: AppColors.textPrimaryLight,
    ),
    bodyLarge: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: AppColors.textPrimaryLight,
    ),
    bodyMedium: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.textSecondaryLight,
    ),
    labelSmall: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w300,
      fontSize: 12,
      color: AppColors.textDisabledLight,
    ),
  );

  static TextTheme dark = TextTheme(
    titleLarge: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 22,
      color: AppColors.textPrimaryDark,
    ),
    titleMedium: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: AppColors.textPrimaryDark,
    ),
    bodyLarge: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.textSecondaryDark,
    ),
    labelSmall: const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w300,
      fontSize: 12,
      color: AppColors.textDisabledDark,
    ),
  );
}
