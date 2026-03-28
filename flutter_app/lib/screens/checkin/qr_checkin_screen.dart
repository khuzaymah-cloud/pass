import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../extensions/context_ext.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';

const _kBlue = AppColors.accent;

class QrCheckinScreen extends ConsumerWidget {
  const QrCheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSub = ref.watch(activeSubscriptionProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull?.user;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: activeSub.when(
          data: (sub) {
            if (sub == null || !sub.isActive) {
              return _buildNoSub(context);
            }
            final qrData =
                'gympass:${user?.id ?? ""}:${sub.id}:${DateTime.now().millisecondsSinceEpoch}';
            return _buildQr(context, qrData, sub.visitsRemaining, sub.maxVisits,
                sub.visitsUsed);
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(color: _kBlue)),
          error: (_, __) => const Center(
              child:
                  Icon(Icons.error_outline, color: AppColors.error, size: 48)),
        ),
      ),
    );
  }

  Widget _buildNoSub(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.error, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.subscriptionExpired,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'اشترك في خطة للحصول على رمز QR',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go('/plans'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(context.l10n.plans,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQr(
      BuildContext context, String qrData, int remaining, int max, int used) {
    final progress = max > 0 ? used / max : 0.0;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                      color: _kBlue, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(context.l10n.qrCheckin,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const Spacer(),
        // QR container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kBlue.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                  color: _kBlue.withValues(alpha: 0.08),
                  blurRadius: 40,
                  spreadRadius: 0),
            ],
          ),
          child: Column(
            children: [
              // QR code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200,
                  eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square, color: Color(0xFF1A1A2E)),
                  dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1A1A2E)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Instructions
              const Text(
                'أظهر هذا الرمز للموظف في النادي',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Visits info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bgElevated),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: AppColors.bgElevated,
                      valueColor: const AlwaysStoppedAnimation(_kBlue),
                    ),
                    Text('$remaining',
                        style: const TextStyle(
                            color: _kBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$remaining زيارة متبقية',
                        style: const TextStyle(
                            color: _kBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text('من أصل $max زيارة',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Tip
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: AppColors.textHint, size: 16),
              SizedBox(width: 6),
              Text('زيارة واحدة لكل نادي يومياً',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
