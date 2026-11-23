import 'package:flutter/material.dart';

import '../models/recall_item.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF0F5C99);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF8FAFC),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF60A5FA),
      brightness: Brightness.dark,
      surface: const Color(0xFF0B1120),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0B1120),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: const Color(0xFF0B1120),
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF131C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF131C2E),
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class RiskVisualStyle {
  const RiskVisualStyle({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final Color border;

  static RiskVisualStyle of(RiskCategory category, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (category) {
      case RiskCategory.microbiologico:
        return RiskVisualStyle(
          icon: Icons.coronavirus_outlined,
          foreground: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
          background: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
          border: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
        );
      case RiskCategory.allergeni:
        return RiskVisualStyle(
          icon: Icons.warning_amber_rounded,
          foreground: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
          background: isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB),
          border: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
        );
      case RiskCategory.chimico:
        return RiskVisualStyle(
          icon: Icons.science_outlined,
          foreground: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF6D28D9),
          background: isDark ? const Color(0xFF2E1065) : const Color(0xFFF5F3FF),
          border: isDark ? const Color(0xFF4C1D95) : const Color(0xFFDDD6FE),
        );
      case RiskCategory.fisico:
        return RiskVisualStyle(
          icon: Icons.broken_image_outlined,
          foreground: isDark ? const Color(0xFF67E8F9) : const Color(0xFF0E7490),
          background: isDark ? const Color(0xFF083344) : const Color(0xFFECFEFF),
          border: isDark ? const Color(0xFF155E75) : const Color(0xFFA5F3FC),
        );
      case RiskCategory.altro:
        return RiskVisualStyle(
          icon: Icons.info_outline_rounded,
          foreground: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          background: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          border: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        );
    }
  }
}
