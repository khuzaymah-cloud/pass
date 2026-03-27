import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/subscription_provider.dart';
import '../../services/subscription_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

class PaymentStubScreen extends ConsumerStatefulWidget {
  final String subscriptionId;
  const PaymentStubScreen({super.key, required this.subscriptionId});

  @override
  ConsumerState<PaymentStubScreen> createState() => _PaymentStubScreenState();
}

class _PaymentStubScreenState extends ConsumerState<PaymentStubScreen> {
  bool _isLoading = false;

  Future<void> _simulatePayment() async {
    setState(() => _isLoading = true);
    try {
      final service = SubscriptionService();
      final initResult = await service.initiatePayment(widget.subscriptionId);
      final gatewayRef = initResult['gateway_ref'] as String;
      await service.simulatePayment(gatewayRef);
      ref.invalidate(activeSubscriptionProvider);
      if (mounted) context.go('/success');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.payment)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.payment_rounded,
                  color: AppColors.neonPrimary,
                  size: 64,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.payment,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: context.l10n.simulatePayment,
                  onPressed: _simulatePayment,
                  isLoading: _isLoading,
                  icon: Icons.bolt_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.paymentComingSoon,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
