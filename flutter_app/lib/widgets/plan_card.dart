import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../models/plan.dart';
import 'glass_card.dart';
import 'neon_badge.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final String lang;
  final String currencySymbol;
  final bool isRecommended;
  final VoidCallback? onTap;

  const PlanCard({
    super.key,
    required this.plan,
    this.lang = 'en',
    this.currencySymbol = 'JD',
    this.isRecommended = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: isRecommended ? AppRadius.xl : AppRadius.lg,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeonBadge(label: plan.name(lang)),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neonPrimary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      '★ Recommended',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.priceLocal.toStringAsFixed(0),
                  style: const TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 6),
                  child: Text(
                    currencySymbol,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (plan.durationMonths > 1) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 6),
                    child: Text(
                      '(${(plan.priceLocal / plan.durationMonths).toStringAsFixed(0)} $currencySymbol/mo)',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${plan.maxVisits} visits · ${plan.validityDays} days · ${plan.gymTierAccess} gyms',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...plan.features(lang).map(
                  (f) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.neonPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
