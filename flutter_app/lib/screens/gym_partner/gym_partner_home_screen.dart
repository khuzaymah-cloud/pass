import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gym_partner_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/shimmer_loader.dart';
import 'package:go_router/go_router.dart';

class GymPartnerHomeScreen extends ConsumerWidget {
  const GymPartnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final stats = ref.watch(gymPartnerStatsProvider);
    final user = authState.valueOrNull?.user;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, ${user?.fullName ?? 'Partner'}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Gym Partner Dashboard',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () =>
                          ref.read(authStateProvider.notifier).logout(),
                    ),
                  ],
                ),
              ),
            ),

            // Scan QR Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GestureDetector(
                  onTap: () => context.go('/partner/scan'),
                  child: GlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.neonPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.neonPrimary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan Member QR',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap to scan and verify check-in',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.neonPrimary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: stats.when(
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          StatCard(
                            label: 'Today',
                            value: '${data['visits_today'] ?? 0}',
                            icon: Icons.today_rounded,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          StatCard(
                            label: 'This Month',
                            value: '${data['visits_month'] ?? 0}',
                            icon: Icons.calendar_month_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          StatCard(
                            label: 'All Time',
                            value: '${data['visits_total'] ?? 0}',
                            icon: Icons.bar_chart_rounded,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          StatCard(
                            label: 'Earnings (Month)',
                            value:
                                '${(data['earnings_month'] ?? 0.0).toStringAsFixed(2)} JD',
                            icon: Icons.payments_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () => Column(
                    children: List.generate(
                        2,
                        (_) => const Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.sm),
                              child: ShimmerLoader(height: 90),
                            )),
                  ),
                  error: (e, _) => const GlassCard(
                    child: Column(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.warning, size: 40),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'No gym linked yet',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Ask admin to assign a gym to your account',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Recent check-ins
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Recent Check-ins',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            stats.when(
              data: (data) {
                final recent = (data['recent_checkins'] as List?) ?? [];
                if (recent.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No check-ins yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  sliver: SliverList.separated(
                    itemCount: recent.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (_, i) {
                      final item = recent[i] as Map<String, dynamic>;
                      final time =
                          DateTime.tryParse(item['checked_in_at'] ?? '');
                      return GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.neonPrimary.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.neonPrimary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['member_name'] ?? 'Member',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${item['plan_tier'] ?? ''} • ${item['daily_rate_paid']?.toStringAsFixed(2) ?? '0.00'} JD',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (time != null)
                              Text(
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}
