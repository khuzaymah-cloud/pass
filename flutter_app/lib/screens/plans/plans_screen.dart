import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/plan_provider.dart';
import '../../services/subscription_service.dart';
import '../../widgets/plan_card.dart';
import '../../widgets/shimmer_loader.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  static const _durations = [
    (value: 1, label: '1 Month'),
    (value: 3, label: '3 Months'),
    (value: 6, label: '6 Months'),
    (value: 12, label: '1 Year'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDuration = ref.watch(selectedDurationProvider);
    final plans = ref.watch(filteredPlanListProvider);
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.plans)),
      body: Column(
        children: [
          // Duration selector
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: _durations.map((d) {
                final isSelected = d.value == selectedDuration;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _DurationChip(
                      label: d.label,
                      isSelected: isSelected,
                      onTap: () => ref
                          .read(selectedDurationProvider.notifier)
                          .state = d.value,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Plan cards
          Expanded(
            child: plans.when(
              data: (list) => ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, i) {
                  final plan = list[i];
                  return PlanCard(
                    plan: plan,
                    lang: lang,
                    isRecommended: plan.tier == 'gold',
                    onTap: () => _subscribe(context, plan.id),
                  );
                },
              ),
              loading: () => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: List.generate(
                    4,
                    (_) => const Padding(
                      padding:
                          EdgeInsetsDirectional.only(bottom: AppSpacing.md),
                      child: ShimmerLoader(height: 200),
                    ),
                  ),
                ),
              ),
              error: (e, _) => Center(
                child:
                    Text('$e', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe(BuildContext context, String planId) async {
    try {
      final sub = await SubscriptionService().create(planId);
      if (context.mounted) {
        context.go('/payment-stub?sub_id=${sub.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonPrimary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.neonPrimary
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
