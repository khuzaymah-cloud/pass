import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
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

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('رمز QR للنادي', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/partner'),
        ),
      ),
      body: gymAsync.when(
        data: (gym) => _buildQrDisplay(gym),
        loading: () => const Center(child: CircularProgressIndicator(color: _kBlue)),
        error: (_, __) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48),
              SizedBox(height: 12),
              Text('لا يوجد نادي مرتبط بحسابك', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrDisplay(Map<String, dynamic> gym) {
    final gymId = gym['id'] as String;
    final gymName = (gym['name_ar'] as String?) ?? (gym['name_en'] as String?) ?? 'النادي';
    final qrData = '1pass-gym:$gymId';

    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'اعرض هذا الرمز للأعضاء لمسحه',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          textAlign: TextAlign.center,
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
              const Text(
                'يمسح العضو هذا الرمز لتسجيل دخوله',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: AppColors.textHint, size: 16),
              SizedBox(width: 6),
              Text('الرمز ثابت — لا يتغير', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
