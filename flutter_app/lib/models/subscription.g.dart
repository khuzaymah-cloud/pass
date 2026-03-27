// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  planId: json['plan_id'] as String,
  countryId: (json['country_id'] as num).toInt(),
  status: json['status'] as String,
  pricePaid: (json['price_paid'] as num).toDouble(),
  dailyRate: (json['daily_rate'] as num).toDouble(),
  maxVisits: (json['max_visits'] as num?)?.toInt() ?? 30,
  validityDays: (json['validity_days'] as num?)?.toInt() ?? 30,
  visitsUsed: (json['visits_used'] as num?)?.toInt() ?? 0,
  visitsRemaining: (json['visits_remaining'] as num?)?.toInt() ?? 30,
  walletBalance: (json['wallet_balance'] as num).toDouble(),
  startedAt: json['started_at'] as String?,
  expiresAt: json['expires_at'] as String?,
  autoRenew: json['auto_renew'] as bool? ?? false,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'plan_id': instance.planId,
      'country_id': instance.countryId,
      'status': instance.status,
      'price_paid': instance.pricePaid,
      'daily_rate': instance.dailyRate,
      'max_visits': instance.maxVisits,
      'validity_days': instance.validityDays,
      'visits_used': instance.visitsUsed,
      'visits_remaining': instance.visitsRemaining,
      'wallet_balance': instance.walletBalance,
      'started_at': instance.startedAt,
      'expires_at': instance.expiresAt,
      'auto_renew': instance.autoRenew,
      'created_at': instance.createdAt,
    };
