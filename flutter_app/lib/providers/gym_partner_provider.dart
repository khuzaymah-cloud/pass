import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

final gymPartnerStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final res = await ApiClient().dio.get('/gyms/my-gym/stats');
  return res.data as Map<String, dynamic>;
});

class ScanResult {
  final bool success;
  final String message;
  final String? memberName;
  final String? planTier;
  final int? visitsRemaining;
  final double? dailyRate;

  const ScanResult({
    required this.success,
    required this.message,
    this.memberName,
    this.planTier,
    this.visitsRemaining,
    this.dailyRate,
  });
}

final scanCheckinProvider =
    FutureProvider.autoDispose.family<ScanResult, String>((ref, qrData) async {
  // QR format: gympass:{userId}:{subId}:{timestamp}
  final parts = qrData.split(':');
  if (parts.length < 3 || parts[0] != 'gympass') {
    return const ScanResult(success: false, message: 'Invalid QR code');
  }
  final userId = parts[1];
  final subId = parts[2];

  try {
    final res = await ApiClient().dio.post('/gyms/scan-checkin', data: {
      'user_id': userId,
      'subscription_id': subId,
    });
    final data = res.data as Map<String, dynamic>;
    return ScanResult(
      success: true,
      message: 'Check-in successful!',
      memberName: data['member_name'] as String?,
      planTier: data['plan_tier'] as String?,
      visitsRemaining: data['visits_remaining'] as int?,
      dailyRate: (data['daily_rate_paid'] as num?)?.toDouble(),
    );
  } catch (e) {
    String msg = 'Check-in failed';
    if (e is Exception) {
      final str = e.toString();
      if (str.contains('detail')) {
        final match = RegExp(r'"detail"\s*:\s*"([^"]+)"').firstMatch(str);
        if (match != null) msg = match.group(1)!;
      }
    }
    return ScanResult(success: false, message: msg);
  }
});
