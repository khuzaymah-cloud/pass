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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(planListProvider);
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.plans)),
      body: plans.when(
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) {
            final plan = list[i];
            return PlanCard(
              plan: plan,
              lang: lang,
              isRecommended: plan.tier == 'gold',
              onTap: () async {
                try {
                  final sub = await SubscriptionService().create(plan.id);
                  if (context.mounted) {
                    context.go('/payment-stub?sub_id=${sub.id}');
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
            );
          },
        ),
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsetsDirectional.only(bottom: AppSpacing.md),
                child: ShimmerLoader(height: 200),
              ),
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}
