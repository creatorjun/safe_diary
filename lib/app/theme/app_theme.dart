import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // colors.png 이미지에서 추출한 색상 정의
  static const Color _primary = Color(0xFF48319D);
  static const Color _secondary = Color(0xFFC427FB);
  static const Color _tertiary = Color(0xFFE0D9FF);
  static const Color _darkSurface = Color(0xFF1F1D47);

  static const Color _lightOnSurface = Color(0xFF000000);
  static const Color _lightOnSurfaceVariant = Color(0xFF3C3C43);

  static const Color _darkOnSurface = Color(0xFFFFFFFF);
  static const Color _darkOnSurfaceVariant = Color(0xFFEBEBF5);

  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // 커스텀 색상 스킴 적용
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.white,
      tertiary: _tertiary,
      onTertiary: _primary,
      error: Colors.red.shade700,
      onError: Colors.white,
      surface: const Color(0xFFFDFBFF),
      onSurface: _lightOnSurface,
      surfaceContainerHighest: const Color(0xFFF7F2F9),
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightOnSurfaceVariant.withAlpha(128),
    ),
    // 전달받은 세부 컴포넌트 테마 설정 유지
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    useMaterial3: true,
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // 커스텀 색상 스킴 적용
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.white,
      tertiary: _tertiary,
      onTertiary: _primary,
      error: Colors.red.shade400,
      onError: Colors.black,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceContainerHighest: const Color(0xFF2a2850),
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkOnSurfaceVariant.withAlpha(128),
    ),
    // 전달받은 세부 컴포넌트 테마 설정 유지
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    useMaterial3: true,
  );
}