import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../extensions/context_ext.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

const _kBlue = AppColors.accent;

const _kCategories = [
  (icon: Icons.fitness_center, label: 'صالات رياضية', key: 'gym'),
  (icon: Icons.sports_kabaddi, label: 'فنون قتالية', key: 'martial'),
  (icon: Icons.sports_gymnastics, label: 'كروس فت', key: 'crossfit'),
  (icon: Icons.self_improvement, label: 'يوغا', key: 'yoga'),
  (icon: Icons.spa, label: 'سبا', key: 'spa'),
  (icon: Icons.pool, label: 'مسابح', key: 'pool'),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final activeSub = ref.watch(activeSubscriptionProvider);
    final user = authState.valueOrNull?.user;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _kBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (user?.fullName ?? 'م').substring(0, 1),
                        style: const TextStyle(
                            color: _kBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.hey(user?.fullName ?? ''),
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          'عمّان, الأردن',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Subscription banner ───
              activeSub.when(
                data: (sub) {
                  if (sub == null) {
                    return _PromoBanner(
                      title: 'اشترك الآن في 1Pass',
                      subtitle: 'اشتراك واحد، ادخل أي نادي في الشبكة',
                      onTap: () => context.go('/plans'),
                    );
                  }
                  return _SubBanner(
                    visitsUsed: sub.visitsUsed,
                    maxVisits: sub.maxVisits,
                    daysRemaining: sub.daysRemaining,
                  );
                },
                loading: () => const SizedBox(
                    height: 120,
                    child: Center(
                        child: CircularProgressIndicator(color: _kBlue))),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // ─── Categories header ───
              Row(
                children: [
                  Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                          color: _kBlue,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  const Text('الفئات',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),

              const SizedBox(height: 16),

              // ─── Categories grid ───
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: _kCategories.length,
                itemBuilder: (_, i) {
                  final cat = _kCategories[i];
                  return GestureDetector(
                    onTap: () => context.go('/plans'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.bgElevated),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _kBlue.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat.icon, color: _kBlue, size: 26),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cat.label,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Promo Banner ───

class _PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PromoBanner(
      {required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_kBlue, _kBlue.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('اشترك الآن',
                        style: TextStyle(
                            color: _kBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.fitness_center_rounded,
                color: Colors.white, size: 48),
          ],
        ),
      ),
    );
  }
}

// ─── Active Subscription Banner ───

class _SubBanner extends StatelessWidget {
  final int visitsUsed;
  final int maxVisits;
  final int daysRemaining;

  const _SubBanner(
      {required this.visitsUsed,
      required this.maxVisits,
      required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    final remaining = maxVisits - visitsUsed;
    final progress = maxVisits > 0 ? visitsUsed / maxVisits : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.bgElevated,
                  valueColor: const AlwaysStoppedAnimation(_kBlue),
                ),
                Text('$remaining',
                    style: const TextStyle(
                        color: _kBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$remaining زيارة متبقية',
                    style: const TextStyle(
                        color: _kBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('$daysRemaining يوم متبقي',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
