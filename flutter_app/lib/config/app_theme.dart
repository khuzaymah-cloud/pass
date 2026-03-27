import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonPrimary,
          secondary: AppColors.neonDim,
          surface: AppColors.bgCard,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgSecondary,
          selectedItemColor: AppColors.neonPrimary,
          unselectedItemColor: AppColors.textHint,
        ),
        fontFamily: 'Inter',
      );

  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBgPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.lightNeonPrimary,
          secondary: AppColors.neonDim,
          surface: AppColors.lightBgCard,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightBgCard,
          selectedItemColor: AppColors.lightNeonPrimary,
          unselectedItemColor: AppColors.lightTextSecondary,
        ),
        fontFamily: 'Inter',
      );
}
