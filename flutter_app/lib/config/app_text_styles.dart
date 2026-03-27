import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _inter = 'Inter';
  static const _kufi = 'NotoKufiArabic';

  static String _family(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? _kufi : _inter;
  }

  static TextStyle display(BuildContext context) => TextStyle(
        fontFamily: _family(context),
        fontSize: 32,
        fontWeight: FontWeight.w700,
      );

  static TextStyle title(BuildContext context) => TextStyle(
        fontFamily: _family(context),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontFamily: _family(context),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: _family(context),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontFamily: _family(context),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
}
