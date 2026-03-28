import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentLight,
          surface: AppColors.bgCard,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgSecondary,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textHint,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
        fontFamily: 'Inter',
      );

  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBgPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.accentLight,
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
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.lightTextSecondary,
        ),
        fontFamily: 'Inter',
      );
}
