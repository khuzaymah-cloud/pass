import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'plan_id')
  final String planId;
  @JsonKey(name: 'country_id')
  final int countryId;
  final String status;
  @JsonKey(name: 'price_paid')
  final double pricePaid;
  @JsonKey(name: 'daily_rate')
  final double dailyRate;
  @JsonKey(name: 'max_visits')
  final int maxVisits;
  @JsonKey(name: 'validity_days')
  final int validityDays;
  @JsonKey(name: 'visits_used')
  final int visitsUsed;
  @JsonKey(name: 'visits_remaining')
  final int visitsRemaining;
  @JsonKey(name: 'wallet_balance')
  final double walletBalance;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;
  @JsonKey(name: 'auto_renew')
  final bool autoRenew;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.countryId,
    required this.status,
    required this.pricePaid,
    required this.dailyRate,
    this.maxVisits = 30,
    this.validityDays = 30,
    this.visitsUsed = 0,
    this.visitsRemaining = 30,
    required this.walletBalance,
    this.startedAt,
    this.expiresAt,
    this.autoRenew = false,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';

  int get daysRemaining {
    if (expiresAt == null) return 0;
    final exp = DateTime.parse(expiresAt!);
    final diff = exp.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}
