import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// # 텍스트 스타일 Theme Extension
///
/// 사용법:
/// `Theme.of(context).extension<AppTextStyles>()!.titleLarge`
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.titleLarge,
    required this.titleMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.labelLarge,
  });

  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle labelLarge;

  @override
  ThemeExtension<AppTextStyles> copyWith({
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? labelLarge,
  }) {
    return AppTextStyles(
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      labelLarge: labelLarge ?? this.labelLarge,
    );
  }

  @override
  ThemeExtension<AppTextStyles> lerp(
      covariant ThemeExtension<AppTextStyles>? other,
      double t,
      ) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
    );
  }
}

/// # 간격 Theme Extension
///
/// 사용법:
/// `SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium)`
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.small = 8.0,
    this.medium = 16.0,
    this.large = 24.0,
  });

  final double small;
  final double medium;
  final double large;

  static const AppSpacing regular = AppSpacing();

  @override
  ThemeExtension<AppSpacing> copyWith({
    double? small,
    double? medium,
    double? large,
  }) {
    return AppSpacing(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  ThemeExtension<AppSpacing> lerp(
      covariant ThemeExtension<AppSpacing>? other,
      double t,
      ) {
    return this;
  }
}

/// # 브랜드 색상 Theme Extension
///
/// 사용법:
/// `Theme.of(context).extension<AppBrandColors>()!.naver`
@immutable
class AppBrandColors extends ThemeExtension<AppBrandColors> {
  const AppBrandColors({
    required this.naver,
    required this.kakao,
  });

  final Color naver;
  final Color kakao;

  static const AppBrandColors regular = AppBrandColors(
    naver: Color(0xFF03C75A),
    kakao: Color(0xFFFEE500),
  );

  @override
  ThemeExtension<AppBrandColors> copyWith({
    Color? naver,
    Color? kakao,
  }) {
    return AppBrandColors(
      naver: naver ?? this.naver,
      kakao: kakao ?? this.kakao,
    );
  }

  @override
  ThemeExtension<AppBrandColors> lerp(
      covariant ThemeExtension<AppBrandColors>? other,
      double t,
      ) {
    if (other is! AppBrandColors) {
      return this;
    }
    return AppBrandColors(
      naver: Color.lerp(naver, other.naver, t)!,
      kakao: Color.lerp(kakao, other.kakao, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const Color _primary = Color(0xFF693EFE);

  static final AppTextStyles _lightTextStyles = AppTextStyles(
    titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: const TextStyle(fontSize: 14),
    labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  static final AppTextStyles _darkTextStyles = _lightTextStyles;

  static final CardThemeData _cardThemeData = CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  );

  static final InputDecorationTheme _inputDecorationTheme =
  InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
  OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static final FilledButtonThemeData _filledButtonTheme =
  FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.light,
    primary: _primary,
    onPrimary: Colors.white,
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF000000),
    onSurfaceVariant: const Color(0xFF3C3C43),
    error: Colors.red.shade700,
    onError: Colors.white,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.dark,
    primary: _primary,
    onPrimary: Colors.white,
    surface: const Color(0xFF1F1D47),
    onSurface: const Color(0xFFFFFFFF),
    onSurfaceVariant: const Color(0xFFEBEBF5),
    error: Colors.red.shade400,
    onError: Colors.black,
  );

  static ThemeData get light {
    final themeData = FlexThemeData.light(
      colorScheme: _lightColorScheme,
      scaffoldBackground: const Color(0xFFF4F3F9),
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    );
    return themeData.copyWith(
      cardTheme: _cardThemeData.copyWith(
        color: _lightColorScheme.surface.withAlpha(180),
      ),
      inputDecorationTheme: _inputDecorationTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      extensions: <ThemeExtension<dynamic>>[
        _lightTextStyles,
        AppSpacing.regular,
        AppBrandColors.regular,
      ],
    );
  }

  static ThemeData get dark {
    final themeData = FlexThemeData.dark(
      colorScheme: _darkColorScheme,
      scaffoldBackground: const Color(0xFF141233),
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    );
    return themeData.copyWith(
      cardTheme: _cardThemeData.copyWith(
        color: themeData.colorScheme.surfaceContainerHighest.withAlpha(180),
      ),
      inputDecorationTheme: _inputDecorationTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      extensions: <ThemeExtension<dynamic>>[
        _darkTextStyles,
        AppSpacing.regular,
        AppBrandColors.regular,
      ],
    );
  }
}