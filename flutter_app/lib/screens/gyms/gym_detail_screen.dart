import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/gym_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../services/checkin_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/shimmer_loader.dart';

class GymDetailScreen extends ConsumerWidget {
  final String gymId;
  const GymDetailScreen({super.key, required this.gymId});

  static const _tierOrder = ['standard', 'gold', 'platinum', 'diamond'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymAsync = ref.watch(gymDetailProvider(gymId));
    final activeSub = ref.watch(activeSubscriptionProvider);
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: gymAsync.when(
        data: (gym) {
          final sub = activeSub.valueOrNull;
          // Server validates tier access; kept for future UI use
          final _ =
              sub != null &&
              sub.isActive &&
              _tierOrder.indexOf(gym.tier) <=
                  _tierOrder.indexOf(
                    sub.planId,
                  );
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(gym.name(lang)),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.neonGlow, AppColors.bgPrimary],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        gym.nameEn.substring(0, 1),
                        style: const TextStyle(
                          color: AppColors.neonPrimary,
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NeonBadge(label: gym.tier),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          Text(
                            ' ${gym.rating.toStringAsFixed(1)} (${gym.totalReviews})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        gym.address,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Opening hours
                      Text(
                        context.l10n.openingHours,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GlassCard(
                        child: Column(
                          children: (gym.openingHours ?? {}).entries.map((e) {
                            final day = e.key;
                            final hours =
                                e.value as Map<String, dynamic>? ?? {};
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(
                                bottom: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${hours['open']} - ${hours['close']}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Amenities
                      if (gym.amenities?.isNotEmpty == true) ...[
                        Text(
                          context.l10n.amenities,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: gym.amenities!
                              .map(
                                (a) => Chip(
                                  label: Text(
                                    a,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: AppColors.bgElevated,
                                  side: const BorderSide(
                                    color: AppColors.neonBorder,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: context.l10n.checkInHere,
                        icon: Icons.qr_code_scanner_rounded,
                        onPressed: () async {
                          try {
                            await CheckinService().checkin(gymId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Checked in!'),
                                  backgroundColor: AppColors.neonPrimary,
                                ),
                              );
                              ref.invalidate(activeSubscriptionProvider);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: ShimmerLoader(height: 300)),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
