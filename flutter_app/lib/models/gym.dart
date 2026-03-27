import 'package:json_annotation/json_annotation.dart';

part 'gym.g.dart';

@JsonSerializable()
class Gym {
  final String id;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  final String tier;
  final String address;
  final double lat;
  final double lng;
  final String? phone;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  final List<dynamic>? photos;
  @JsonKey(name: 'opening_hours')
  final Map<String, dynamic>? openingHours;
  final List<String>? amenities;
  final List<String>? categories;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  final double rating;
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @JsonKey(name: 'country_id')
  final int countryId;

  const Gym({
    required this.id,
    required this.nameEn,
    this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.tier,
    required this.address,
    required this.lat,
    required this.lng,
    this.phone,
    this.logoUrl,
    this.coverUrl,
    this.photos,
    this.openingHours,
    this.amenities,
    this.categories,
    this.isActive = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.countryId,
  });

  String name(String lang) => lang == 'ar' ? (nameAr ?? nameEn) : nameEn;

  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);
  Map<String, dynamic> toJson() => _$GymToJson(this);
}
