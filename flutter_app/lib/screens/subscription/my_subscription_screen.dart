import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/visits_ring.dart';
import '../../widgets/subscription_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/shimmer_loader.dart';

class MySubscriptionScreen extends ConsumerWidget {
  const MySubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSub = ref.watch(activeSubscriptionProvider);
    final allSubs = ref.watch(subscriptionListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.mySubscription)),
      body: activeSub.when(
        data: (sub) {
          if (sub == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.card_membership_rounded,
                    color: AppColors.textHint,
                    size: 64,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.noActiveSubscription,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.xxl,
                    ),
                    child: PrimaryButton(
                      label: context.l10n.getStarted,
                      onPressed: () => context.go('/plans'),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sub.status.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          SubscriptionBadge(status: sub.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      VisitsRing(
                        visitsUsed: sub.visitsUsed,
                        maxVisits: sub.maxVisits,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        context.l10n.daysRemaining(sub.daysRemaining),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.l10n.walletBalance(
                          sub.walletBalance.toStringAsFixed(2),
                          'JD',
                        ),
                        style: const TextStyle(
                          color: AppColors.neonPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // History
                allSubs.when(
                  data: (subs) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.checkinHistory,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...subs.map(
                        (s) => Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: GlassCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${s.visitsUsed}/${s.maxVisits} visits',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      s.status,
                                      style: const TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SubscriptionBadge(status: s.status),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const ShimmerLoader(height: 100),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: ShimmerLoader(height: 300)),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
