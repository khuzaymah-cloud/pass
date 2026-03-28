import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../providers/gym_partner_provider.dart';
import '../../services/api_client.dart';

const _kBlue = AppColors.accent;

class GymPartnerScanScreen extends ConsumerStatefulWidget {
  const GymPartnerScanScreen({super.key});

  @override
  ConsumerState<GymPartnerScanScreen> createState() =>
      _GymPartnerScanScreenState();
}

class _GymPartnerScanScreenState extends ConsumerState<GymPartnerScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  ScanResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _result != null) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final qrData = barcode.rawValue!;
    if (!qrData.startsWith('gympass:')) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    final parts = qrData.split(':');
    if (parts.length < 3) {
      setState(() {
        _result = const ScanResult(success: false, message: 'رمز QR غير صالح');
        _isProcessing = false;
      });
      return;
    }

    try {
      final res = await ApiClient().dio.post('/gyms/scan-checkin', data: {
        'user_id': parts[1],
        'subscription_id': parts[2],
      });
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _result = ScanResult(
          success: true,
          message: 'تم تسجيل الدخول بنجاح!',
          memberName: data['member_name'] as String?,
          planTier: data['plan_tier'] as String?,
          visitsRemaining: data['visits_remaining'] as int?,
          dailyRate: (data['daily_rate_paid'] as num?)?.toDouble(),
        );
        _isProcessing = false;
      });
    } catch (e) {
      String msg = 'فشل تسجيل الدخول';
      final str = e.toString();
      if (str.contains('not active')) {
        msg = 'الاشتراك غير فعّال';
      } else if (str.contains('expired')) {
        msg = 'الاشتراك منتهي';
      } else if (str.contains('Duplicate') || str.contains('already')) {
        msg = 'تم التسجيل مسبقاً اليوم';
      } else if (str.contains('tier')) {
        msg = 'فئة الخطة غير مسموح بها لهذا النادي';
      } else if (str.contains('not found')) {
        msg = 'العضو أو الاشتراك غير موجود';
      }
      setState(() {
        _result = ScanResult(success: false, message: msg);
        _isProcessing = false;
      });
    }
  }

  void _resetScan() {
    setState(() {
      _result = null;
      _isProcessing = false;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('مسح رمز العضو',
            style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.go('/partner'),
        ),
      ),
      body: _result != null ? _buildResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'وجّه الكاميرا نحو رمز QR الخاص بالعضو',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                  // Scan frame overlay
                  Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isProcessing ? AppColors.warning : _kBlue,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    const Center(
                        child: CircularProgressIndicator(color: _kBlue)),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: AppColors.textHint, size: 16),
              SizedBox(width: 6),
              Text('يتم المسح تلقائياً عند اكتشاف الرمز',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final r = _result!;
    final isSuccess = r.success;
    final statusColor = isSuccess ? AppColors.success : AppColors.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withValues(alpha: 0.12),
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: statusColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              r.message,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            if (isSuccess && r.memberName != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.bgElevated),
                ),
                child: Column(
                  children: [
                    _DetailRow(label: 'العضو', value: r.memberName!),
                    _divider(),
                    _DetailRow(
                        label: 'الخطة',
                        value: (r.planTier ?? '').toUpperCase()),
                    _divider(),
                    _DetailRow(
                        label: 'المبلغ المدفوع',
                        value: '${r.dailyRate?.toStringAsFixed(3) ?? '0'} د.أ'),
                    _divider(),
                    _DetailRow(
                        label: 'الزيارات المتبقية',
                        value: '${r.visitsRemaining ?? 0}'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _resetScan,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('مسح آخر',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(color: AppColors.bgElevated, height: 1),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
