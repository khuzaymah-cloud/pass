import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class SubscriptionBadge extends StatelessWidget {
  final String status;

  const SubscriptionBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      'active' => (AppColors.neonPrimary, AppColors.neonGlow),
      'expired' => (AppColors.error, AppColors.error.withValues(alpha: 0.15)),
      'pending' => (AppColors.warning, AppColors.warning.withValues(alpha: 0.15)),
      _ => (AppColors.textHint, AppColors.bgElevated),
    };

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
