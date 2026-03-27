import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/gym_provider.dart';
import '../../widgets/gym_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loader.dart';

class GymMapScreen extends ConsumerStatefulWidget {
  const GymMapScreen({super.key});

  @override
  ConsumerState<GymMapScreen> createState() => _GymMapScreenState();
}

class _GymMapScreenState extends ConsumerState<GymMapScreen> {
  String? _selectedTier;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final key = '${_selectedTier ?? ''}|${_searchController.text}';
    final gyms = ref.watch(gymListProvider(key));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: GlassCard(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                ),
                borderRadius: AppRadius.pill,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: context.l10n.findGym,
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    border: InputBorder.none,
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.neonPrimary,
                    ),
                  ),
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
            ),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Row(
                children: ['All', 'standard', 'gold', 'platinum', 'diamond']
                    .map((tier) {
                      final isAll = tier == 'All';
                      final selected = isAll
                          ? _selectedTier == null
                          : _selectedTier == tier;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.sm,
                        ),
                        child: FilterChip(
                          label: Text(tier.toUpperCase()),
                          selected: selected,
                          onSelected: (_) => setState(
                            () => _selectedTier = isAll ? null : tier,
                          ),
                          selectedColor: AppColors.neonGlow,
                          checkmarkColor: AppColors.neonPrimary,
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.neonPrimary
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.bgCard,
                          side: BorderSide(
                            color: selected
                                ? AppColors.neonPrimary
                                : AppColors.neonBorder,
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Gym list
            Expanded(
              child: gyms.when(
                data: (list) => ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => GymCard(
                    gym: list[i],
                    lang: lang,
                    onTap: () => context.go('/gyms/${list[i].id}'),
                  ),
                ),
                loading: () => Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: List.generate(
                      5,
                      (_) => const Padding(
                        padding: EdgeInsetsDirectional.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: ShimmerLoader(height: 80),
                      ),
                    ),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
