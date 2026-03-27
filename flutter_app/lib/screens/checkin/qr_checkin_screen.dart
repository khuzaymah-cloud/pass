import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
class QrCheckinScreen extends ConsumerWidget {
  const QrCheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSub = ref.watch(activeSubscriptionProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull?.user;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: Text(context.l10n.qrCheckin)),
      body: Center(
        child: activeSub.when(
          data: (sub) {
            if (sub == null || !sub.isActive) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.error,
                    size: 64,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.subscriptionExpired,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            }

            final qrData =
                'gympass:${user?.id ?? ""}:${sub.id}:${DateTime.now().millisecondsSinceEpoch}';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing neon ring
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.neonPrimary.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPrimary.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: GlassCard(
                    borderRadius: AppRadius.lg,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 220,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.neonPrimary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.neonPrimary,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  context.l10n.scanAtGym,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${sub.visitsRemaining} ${context.l10n.visitsRemaining(sub.visitsRemaining).split(' ').last}',
                  style: const TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
          loading: () =>
              const CircularProgressIndicator(color: AppColors.neonPrimary),
          error: (_, __) =>
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
        ),
      ),
    );
  }
}
