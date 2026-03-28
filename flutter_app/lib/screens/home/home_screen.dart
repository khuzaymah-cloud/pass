import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../extensions/context_ext.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/gym.dart';

const _kBlue = AppColors.accent;

// Gym categories (only gyms for now)
const _kCategories = [
  (icon: Icons.fitness_center, label: 'كل الأندية', key: ''),
  (icon: Icons.sports_gymnastics, label: 'كروس فت', key: 'crossfit'),
  (icon: Icons.self_improvement, label: 'يوغا', key: 'yoga'),
  (icon: Icons.spa, label: 'سبا', key: 'spa'),
  (icon: Icons.sports_kabaddi, label: 'فنون قتالية', key: 'martial'),
  (icon: Icons.pool, label: 'مسابح', key: 'pool'),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final activeSub = ref.watch(activeSubscriptionProvider);
    final gyms = ref.watch(gymListProvider('$_selectedCategory|'));
    final user = authState.valueOrNull?.user;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    // Avatar
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
              ),
            ),

            // ─── Subscription banner ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: activeSub.when(
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
              ),
            ),

            // ─── Categories ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _kCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, i) {
                      final cat = _kCategories[i];
                      final isSelected = cat.key == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat.key),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kBlue.withValues(alpha: 0.2)
                                    : AppColors.bgCard,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? _kBlue
                                      : AppColors.bgElevated,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(cat.icon,
                                  color: isSelected
                                      ? _kBlue
                                      : AppColors.textSecondary,
                                  size: 24),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.label,
                              style: TextStyle(
                                color: isSelected
                                    ? _kBlue
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ─── Trending section header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                            color: _kBlue,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    const Text('الأندية الرائجة',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            // ─── Gym cards (horizontal scroll) ───
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: gyms.when(
                  data: (list) => list.isEmpty
                      ? const Center(
                          child: Text('لا توجد أندية',
                              style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (_, i) => _GymTrendCard(
                              gym: list[i],
                              onTap: () => context.go('/gyms/${list[i].id}')),
                        ),
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: _kBlue)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ─── All gyms section ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                            color: _kBlue,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    const Text('جميع الأندية',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            // ─── Gym list (vertical) ───
            gyms.when(
              data: (list) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _GymListTile(
                      gym: list[i],
                      onTap: () => context.go('/gyms/${list[i].id}')),
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
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
          // Ring progress
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

// ─── Trending Gym Card (horizontal) ───

class _GymTrendCard extends StatelessWidget {
  final Gym gym;
  final VoidCallback onTap;

  const _GymTrendCard({required this.gym, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bgElevated),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Container(
              height: 130,
              decoration: const BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: gym.coverUrl != null
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(gym.coverUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _coverPlaceholder()),
                    )
                  : _coverPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gym.nameEn,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        gym.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 14),
                      Text(
                        ' (${gym.totalReviews})',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          gym.address,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.textHint.withValues(alpha: 0.3)),
                    ),
                    child: const Text('دخول فوري',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return const Center(
        child: Icon(Icons.fitness_center, color: AppColors.textHint, size: 40));
  }
}

// ─── Gym List Tile (vertical) ───

class _GymListTile extends StatelessWidget {
  final Gym gym;
  final VoidCallback onTap;

  const _GymListTile({required this.gym, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bgElevated),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: gym.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(gym.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                                child: Text(gym.nameEn.substring(0, 1),
                                    style: const TextStyle(
                                        color: _kBlue,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700)),
                              )),
                    )
                  : Center(
                      child: Text(gym.nameEn.substring(0, 1),
                          style: const TextStyle(
                              color: _kBlue,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gym.nameEn,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(gym.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 13),
                      Text(' · ${gym.tier}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(gym.address,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
