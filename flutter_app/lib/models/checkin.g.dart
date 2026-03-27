// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin.dart';

Checkin _$CheckinFromJson(Map<String, dynamic> json) => Checkin(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  gymId: json['gym_id'] as String,
  subscriptionId: json['subscription_id'] as String,
  qrToken: json['qr_token'] as String,
  checkedInAt: json['checked_in_at'] as String,
  checkedOutAt: json['checked_out_at'] as String?,
  status: json['status'] as String,
  dailyRatePaid: _toDouble(json['daily_rate_paid']),
  planTier: json['plan_tier'] as String,
);

Map<String, dynamic> _$CheckinToJson(Checkin instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'gym_id': instance.gymId,
  'subscription_id': instance.subscriptionId,
  'qr_token': instance.qrToken,
  'checked_in_at': instance.checkedInAt,
  'checked_out_at': instance.checkedOutAt,
  'status': instance.status,
  'daily_rate_paid': instance.dailyRatePaid,
  'plan_tier': instance.planTier,
};
