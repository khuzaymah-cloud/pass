import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../extensions/context_ext.dart';
import '../../providers/subscription_provider.dart';
import '../../services/api_client.dart';

const _kBlue = AppColors.accent;

class QrCheckinScreen extends ConsumerStatefulWidget {
  const QrCheckinScreen({super.key});

  @override
  ConsumerState<QrCheckinScreen> createState() => _QrCheckinScreenState();
}

class _QrCheckinScreenState extends ConsumerState<QrCheckinScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  _CheckinResult? _result;

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
    if (!qrData.startsWith('1pass-gym:')) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    final gymId = qrData.substring('1pass-gym:'.length);
    if (gymId.isEmpty) {
      setState(() {
        _result = const _CheckinResult(success: false, message: 'رمز QR غير صالح');
        _isProcessing = false;
      });
      return;
    }

    try {
      final res = await ApiClient().dio.post('/gyms/member-checkin', data: {
        'gym_id': gymId,
      });
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _result = _CheckinResult(
          success: true,
          message: 'تم تسجيل الدخول بنجاح!',
          gymName: data['gym_name'] as String?,
          planTier: data['plan_tier'] as String?,
          visitsRemaining: data['visits_remaining'] as int?,
          dailyRate: (data['daily_rate_paid'] as num?)?.toDouble(),
        );
        _isProcessing = false;
      });
      ref.invalidate(activeSubscriptionProvider);
    } catch (e) {
      String msg = 'فشل تسجيل الدخول';
      final str = e.toString();
      if (str.contains('No active subscription')) {
        msg = 'لا يوجد اشتراك فعّال';
      } else if (str.contains('expired')) {
        msg = 'الاشتراك منتهي';
      } else if (str.contains('Duplicate') || str.contains('already')) {
        msg = 'تم التسجيل مسبقاً اليوم';
      } else if (str.contains('tier')) {
        msg = 'فئة الخطة غير مسموح بها لهذا النادي';
      } else if (str.contains('not found')) {
        msg = 'النادي غير موجود';
      }
      setState(() {
        _result = _CheckinResult(success: false, message: msg);
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
    final activeSub = ref.watch(activeSubscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: activeSub.when(
          data: (sub) {
            if (sub == null || !sub.isActive) return _buildNoSub(context);
            return _result != null
                ? _buildResult(sub.visitsRemaining, sub.maxVisits)
                : _buildScanner(context, sub.visitsRemaining, sub.maxVisits, sub.visitsUsed);
          },
          loading: () => const Center(child: CircularProgressIndicator(color: _kBlue)),
          error: (_, __) => const Center(child: Icon(Icons.error_outline, color: AppColors.error, size: 48)),
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
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.error, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.subscriptionExpired,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'اشترك في خطة للدخول إلى الأندية',
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(context.l10n.plans, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner(BuildContext context, int remaining, int max, int used) {
    final progress = max > 0 ? used / max : 0.0;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: _kBlue, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(context.l10n.qrCheckin, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('امسح رمز QR الموجود في النادي', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 16),
        // Scanner
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  MobileScanner(controller: _controller, onDetect: _onDetect),
                  Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: _isProcessing ? AppColors.warning : _kBlue, width: 3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  if (_isProcessing) const Center(child: CircularProgressIndicator(color: _kBlue)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Visits info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bgElevated),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: progress, strokeWidth: 3, backgroundColor: AppColors.bgElevated, valueColor: const AlwaysStoppedAnimation(_kBlue)),
                    Text('$remaining', style: const TextStyle(color: _kBlue, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('$remaining زيارة متبقية من أصل $max', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: AppColors.textHint, size: 16),
              SizedBox(width: 6),
              Text('زيارة واحدة لكل نادي يومياً', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult(int remaining, int max) {
    final r = _result!;
    final statusColor = r.success ? AppColors.success : AppColors.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor.withValues(alpha: 0.12)),
              child: Icon(r.success ? Icons.check_circle_rounded : Icons.cancel_rounded, color: statusColor, size: 60),
            ),
            const SizedBox(height: 20),
            Text(r.message, style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            if (r.success && r.gymName != null) ...[
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
                    _DetailRow(label: 'النادي', value: r.gymName!),
                    _divider(),
                    _DetailRow(label: 'الخطة', value: (r.planTier ?? '').toUpperCase()),
                    _divider(),
                    _DetailRow(label: 'الزيارات المتبقية', value: '${r.visitsRemaining ?? remaining}'),
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
                label: const Text('مسح آخر', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _CheckinResult {
  final bool success;
  final String message;
  final String? gymName;
  final String? planTier;
  final int? visitsRemaining;
  final double? dailyRate;
  const _CheckinResult({required this.success, required this.message, this.gymName, this.planTier, this.visitsRemaining, this.dailyRate});
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
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
