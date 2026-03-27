import 'package:json_annotation/json_annotation.dart';

part 'plan.g.dart';

@JsonSerializable()
class Plan {
  final String id;
  @JsonKey(name: 'country_id')
  final int countryId;
  final String tier;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  @JsonKey(name: 'price_local')
  final double priceLocal;
  @JsonKey(name: 'daily_rate')
  final double dailyRate;
  @JsonKey(name: 'max_visits')
  final int maxVisits;
  @JsonKey(name: 'validity_days')
  final int validityDays;
  @JsonKey(name: 'gym_tier_access')
  final String gymTierAccess;
  @JsonKey(name: 'features_en')
  final List<dynamic>? featuresEn;
  @JsonKey(name: 'features_ar')
  final List<dynamic>? featuresAr;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  const Plan({
    required this.id,
    required this.countryId,
    required this.tier,
    required this.nameEn,
    required this.nameAr,
    required this.priceLocal,
    required this.dailyRate,
    this.maxVisits = 30,
    this.validityDays = 30,
    required this.gymTierAccess,
    this.featuresEn,
    this.featuresAr,
    this.isActive = true,
    this.sortOrder = 0,
  });

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  List<String> features(String lang) =>
      (lang == 'ar' ? featuresAr : featuresEn)?.cast<String>() ?? [];

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
  Map<String, dynamic> toJson() => _$PlanToJson(this);
}
