// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

Plan _$PlanFromJson(Map<String, dynamic> json) => Plan(
  id: json['id'] as String,
  countryId: (json['country_id'] as num).toInt(),
  tier: json['tier'] as String,
  nameEn: json['name_en'] as String,
  nameAr: json['name_ar'] as String,
  priceLocal: _toDouble(json['price_local']),
  dailyRate: _toDouble(json['daily_rate']),
  maxVisits: (json['max_visits'] as num?)?.toInt() ?? 30,
  validityDays: (json['validity_days'] as num?)?.toInt() ?? 30,
  gymTierAccess: json['gym_tier_access'] as String,
  featuresEn: json['features_en'] as List<dynamic>?,
  featuresAr: json['features_ar'] as List<dynamic>?,
  isActive: json['is_active'] as bool? ?? true,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlanToJson(Plan instance) => <String, dynamic>{
  'id': instance.id,
  'country_id': instance.countryId,
  'tier': instance.tier,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'price_local': instance.priceLocal,
  'daily_rate': instance.dailyRate,
  'max_visits': instance.maxVisits,
  'validity_days': instance.validityDays,
  'gym_tier_access': instance.gymTierAccess,
  'features_en': instance.featuresEn,
  'features_ar': instance.featuresAr,
  'is_active': instance.isActive,
  'sort_order': instance.sortOrder,
};
