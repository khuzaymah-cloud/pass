import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/gym_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/visits_ring.dart';
import '../../widgets/gym_card.dart';
import '../../widgets/shimmer_loader.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final activeSub = ref.watch(activeSubscriptionProvider);
    final featuredGyms = ref.watch(featuredGymsProvider);
    final user = authState.valueOrNull?.user;
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.hey(user?.fullName ?? ''),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Subscription hero card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: activeSub.when(
                  data: (sub) {
                    if (sub == null) {
                      return GlassCard(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.fitness_center_rounded,
                              color: AppColors.neonPrimary,
                              size: 48,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              context.l10n.noActiveSubscription,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton(
                              onPressed: () => context.go('/plans'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.neonPrimary,
                                foregroundColor: Colors.black,
                              ),
                              child: Text(context.l10n.getStarted),
                            ),
                          ],
                        ),
                      );
                    }
                    return GlassCard(
                      child: Row(
                        children: [
                          VisitsRing(
                            visitsUsed: sub.visitsUsed,
                            maxVisits: sub.maxVisits,
                            size: 100,
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.visitsRemaining(
                                    sub.visitsRemaining,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.neonPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.l10n.daysRemaining(sub.daysRemaining),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const ShimmerLoader(height: 120),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    _QuickAction(
                      icon: Icons.qr_code_scanner_rounded,
                      label: context.l10n.checkIn,
                      onTap: () => context.go('/checkin'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _QuickAction(
                      icon: Icons.map_rounded,
                      label: context.l10n.findGym,
                      onTap: () => context.go('/gyms'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _QuickAction(
                      icon: Icons.refresh_rounded,
                      label: context.l10n.renewPlan,
                      onTap: () => context.go('/plans'),
                    ),
                  ],
                ),
              ),
            ),

            // Nearby gyms header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(
                  context.l10n.nearbyGyms,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Gym list
            featuredGyms.when(
              data: (gyms) => SliverPadding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                sliver: SliverList.separated(
                  itemCount: gyms.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => GymCard(
                    gym: gyms[i],
                    lang: lang,
                    onTap: () => context.go('/gyms/${gyms[i].id}'),
                  ),
                ),
              ),
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsetsDirectional.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: ShimmerLoader(height: 80),
                      ),
                    ),
                  ),
                ),
              ),
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, color: AppColors.neonPrimary, size: 28),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
