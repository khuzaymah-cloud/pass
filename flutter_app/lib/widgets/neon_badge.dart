import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class NeonBadge extends StatelessWidget {
  final String label;

  const NeonBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.neonGlow,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.neonBorder, width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.neonPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
