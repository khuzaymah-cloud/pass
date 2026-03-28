import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../extensions/context_ext.dart';
import '../../services/api_client.dart';

const _kBlue = AppColors.accent;

/// Provider to fetch the gym partner's gym data (id, name)
final _myGymProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final res = await ApiClient().dio.get('/gyms/my-gym');
  return res.data as Map<String, dynamic>;
});

class GymPartnerScanScreen extends ConsumerWidget {
  const GymPartnerScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymAsync = ref.watch(_myGymProvider);
    final l = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text(l.gymQrCode, style: const TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/partner'),
        ),
      ),
      body: gymAsync.when(
        data: (gym) => _QrDisplay(gym: gym),
        loading: () => const Center(child: CircularProgressIndicator(color: _kBlue)),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(l.noGymLinkedToAccount, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrDisplay extends StatelessWidget {
  final Map<String, dynamic> gym;
  const _QrDisplay({required this.gym});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final gymId = gym['id'] as String;
    final gymName = (gym['name_ar'] as String?) ?? (gym['name_en'] as String?) ?? l.defaultGymName;
    final qrData = '1pass-gym:$gymId';

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          l.showQrToMembers,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kBlue.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(color: _kBlue.withValues(alpha: 0.08), blurRadius: 40, spreadRadius: 0),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1A1A2E)),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1A1A2E)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                gymName,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l.memberScansThisQr,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: AppColors.textHint, size: 16),
              const SizedBox(width: 6),
              Text(l.qrCodeFixed, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
