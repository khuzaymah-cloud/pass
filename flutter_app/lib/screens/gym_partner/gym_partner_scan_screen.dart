import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../providers/gym_partner_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/info_row.dart';
import '../../services/api_client.dart';

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

    // Parse QR: gympass:{userId}:{subId}:{timestamp}
    final parts = qrData.split(':');
    if (parts.length < 3) {
      setState(() {
        _result =
            const ScanResult(success: false, message: 'Invalid QR code format');
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
          message: 'Check-in successful!',
          memberName: data['member_name'] as String?,
          planTier: data['plan_tier'] as String?,
          visitsRemaining: data['visits_remaining'] as int?,
          dailyRate: (data['daily_rate_paid'] as num?)?.toDouble(),
        );
        _isProcessing = false;
      });
    } catch (e) {
      String msg = 'Check-in failed';
      final str = e.toString();
      if (str.contains('Subscription is not active')) {
        msg = 'Subscription is not active';
      } else if (str.contains('expired')) {
        msg = 'Subscription has expired';
      } else if (str.contains('Duplicate')) {
        msg = 'Already checked in today';
      } else if (str.contains('tier')) {
        msg = 'Plan tier not allowed for this gym';
      } else if (str.contains('not found')) {
        msg = 'Member or subscription not found';
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
        title: const Text('Scan Member QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
          'Point camera at member\'s QR code',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                  // Overlay frame
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isProcessing
                              ? AppColors.warning
                              : AppColors.neonPrimary,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildResult() {
    final r = _result!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (r.success ? AppColors.neonPrimary : AppColors.error)
                    .withValues(alpha: 0.15),
              ),
              child: Icon(
                r.success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: r.success ? AppColors.neonPrimary : AppColors.error,
                size: 60,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              r.message,
              style: TextStyle(
                color: r.success ? AppColors.neonPrimary : AppColors.error,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (r.success && r.memberName != null) ...[
              const SizedBox(height: AppSpacing.xl),
              GlassCard(
                child: Column(
                  children: [
                    InfoRow(label: 'Member', value: r.memberName!),
                    const Divider(color: AppColors.neonBorder, height: 20),
                    InfoRow(
                        label: 'Plan', value: (r.planTier ?? '').toUpperCase()),
                    const Divider(color: AppColors.neonBorder, height: 20),
                    InfoRow(
                        label: 'Rate Paid',
                        value: '${r.dailyRate?.toStringAsFixed(3) ?? '0'} JD'),
                    const Divider(color: AppColors.neonBorder, height: 20),
                    InfoRow(
                        label: 'Visits Left',
                        value: '${r.visitsRemaining ?? 0}'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _resetScan,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text(
                  'Scan Another',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPrimary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
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
