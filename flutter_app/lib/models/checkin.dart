import 'package:json_annotation/json_annotation.dart';

part 'checkin.g.dart';

@JsonSerializable()
class Checkin {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'gym_id')
  final String gymId;
  @JsonKey(name: 'subscription_id')
  final String subscriptionId;
  @JsonKey(name: 'qr_token')
  final String qrToken;
  @JsonKey(name: 'checked_in_at')
  final String checkedInAt;
  @JsonKey(name: 'checked_out_at')
  final String? checkedOutAt;
  final String status;
  @JsonKey(name: 'daily_rate_paid')
  final double dailyRatePaid;
  @JsonKey(name: 'plan_tier')
  final String planTier;

  const Checkin({
    required this.id,
    required this.userId,
    required this.gymId,
    required this.subscriptionId,
    required this.qrToken,
    required this.checkedInAt,
    this.checkedOutAt,
    required this.status,
    required this.dailyRatePaid,
    required this.planTier,
  });

  factory Checkin.fromJson(Map<String, dynamic> json) =>
      _$CheckinFromJson(json);
  Map<String, dynamic> toJson() => _$CheckinToJson(this);
}
