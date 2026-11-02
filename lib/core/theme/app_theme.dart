import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          error: AppColors.error,
          surface: AppColors.background,
          onSurface: AppColors.onSurface,
        ),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        splashFactory: InkSparkle.splashFactory,
      );
}
