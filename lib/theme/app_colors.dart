import 'package:flutter/material.dart';

class AppColors {
  static const Color _primaryBase = Color(0xFF6366F1);
  static const Color _secondaryBase = Color(0xFF8B5CF6);
  static const Color _accentBase = Color(0xFFEC4899);
  
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryDeep = Color(0xFF4338CA);
  
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryDeep = Color(0xFF6D28D9);
  
  static const Color accentLight = Color(0xFFF472B6);
  static const Color accent = Color(0xFFEC4899);
  static const Color accentDark = Color(0xFFDB2777);
  static const Color accentDeep = Color(0xFFBE185D);
  
  static const Color successLight = Color(0xFF34D399);
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  
  static const Color errorLight = Color(0xFFF87171);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  
  static const Color infoLight = Color(0xFF38BDF8);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoDark = Color(0xFF0284C7);
  
  static const Color purpleLight = Color(0xFFC4B5FD);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF7C3AED);
  
  static const Color indigoLight = Color(0xFFA5B4FC);
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoDark = Color(0xFF4F46E5);
  
  static const Color tealLight = Color(0xFF5EEAD4);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0F766E);
  
  static const Color cyanLight = Color(0xFF22D3EE);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanDark = Color(0xFF0891B2);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coolGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF2DD4BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient midnightGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ColorScheme get lightColorScheme => ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryLight,
    onPrimaryContainer: primaryDeep,
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: secondaryLight,
    onSecondaryContainer: secondaryDeep,
    tertiary: accent,
    onTertiary: Colors.white,
    tertiaryContainer: accentLight,
    onTertiaryContainer: accentDeep,
    error: error,
    onError: Colors.white,
    errorContainer: errorLight,
    onErrorContainer: errorDark,
    surface: Colors.white,
    onSurface: Color(0xFF1F2937),
    surfaceContainerHighest: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFF6B7280),
    outline: Color(0xFFD1D5DB),
    outlineVariant: Color(0xFFE5E7EB),
    shadow: Color(0xFF000000),
    onInverseSurface: Color(0xFFF9FAFB),
    inverseSurface: Color(0xFF1F2937),
    inversePrimary: primaryLight,
  );

  static ColorScheme get darkColorScheme => ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLight,
    onPrimary: primaryDeep,
    primaryContainer: primaryDark,
    onPrimaryContainer: primaryLight,
    secondary: secondaryLight,
    onSecondary: secondaryDeep,
    secondaryContainer: secondaryDark,
    onSecondaryContainer: secondaryLight,
    tertiary: accentLight,
    onTertiary: accentDeep,
    tertiaryContainer: accentDark,
    onTertiaryContainer: accentLight,
    error: errorLight,
    onError: errorDark,
    errorContainer: errorDark,
    onErrorContainer: errorLight,
    surface: Color(0xFF1F2937),
    onSurface: Color(0xFFF9FAFB),
    surfaceContainerHighest: Color(0xFF374151),
    onSurfaceVariant: Color(0xFF9CA3AF),
    outline: Color(0xFF4B5563),
    outlineVariant: Color(0xFF374151),
    shadow: Color(0xFF000000),
    onInverseSurface: Color(0xFF1F2937),
    inverseSurface: Color(0xFFF9FAFB),
    inversePrimary: primary,
  );
}

class AppColorPalette {
  static const Color primaryBrand = AppColors.primary;
  static const Color secondaryBrand = AppColors.secondary;
  static const Color accent = AppColors.accent;
  
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;
  static const Color info = AppColors.info;
  
  static const Color purple = AppColors.purple;
  static const Color indigo = AppColors.indigo;
  static const Color teal = AppColors.teal;
  static const Color cyan = AppColors.cyan;

  static List<Color> brandGradient = [AppColors.primary, AppColors.secondary];
  static List<Color> warmGradient = [Color(0xFFFF6B6B), Color(0xFFFF8E53)];
  static List<Color> coolGradient = [Color(0xFF0EA5E9), Color(0xFF2DD4BF)];
  static List<Color> sunsetGradient = [Color(0xFFFF6B6B), Color(0xFFF59E0B)];
  static List<Color> oceanGradient = [Color(0xFF06B6D4), Color(0xFF3B82F6)];
  static List<Color> auroraGradient = [AppColors.primary, AppColors.success, AppColors.cyan];

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return success;
      case 'finance':
        return warning;
      case 'communication':
        return info;
      case 'emergency':
        return error;
      case 'social':
        return purple;
      case 'media':
        return accent;
      case 'calendar':
        return indigo;
      case 'location':
        return teal;
      default:
        return primaryBrand;
    }
  }

  static LinearGradient getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return AppColors.successGradient;
      case 'finance':
        return AppColors.warningGradient;
      case 'communication':
        return AppColors.coolGradient;
      case 'emergency':
        return AppColors.errorGradient;
      case 'social':
        return AppColors.primaryGradient;
      case 'media':
        return AppColors.accentGradient;
      case 'calendar':
        return AppColors.oceanGradient;
      case 'location':
        return const LinearGradient(colors: [teal, cyan]);
      default:
        return AppColors.primaryGradient;
    }
  }
}