// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym.dart';

Gym _$GymFromJson(Map<String, dynamic> json) => Gym(
  id: json['id'] as String,
  nameEn: json['name_en'] as String,
  nameAr: json['name_ar'] as String?,
  descriptionEn: json['description_en'] as String?,
  descriptionAr: json['description_ar'] as String?,
  tier: json['tier'] as String,
  address: json['address'] as String,
  lat: _toDouble(json['lat']),
  lng: _toDouble(json['lng']),
  phone: json['phone'] as String?,
  logoUrl: json['logo_url'] as String?,
  coverUrl: json['cover_url'] as String?,
  photos: json['photos'] as List<dynamic>?,
  openingHours: json['opening_hours'] as Map<String, dynamic>?,
  amenities: (json['amenities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isActive: json['is_active'] as bool? ?? true,
  isFeatured: json['is_featured'] as bool? ?? false,
  rating: _toDouble(json['rating'] ?? 0.0),
  totalReviews: _toInt(json['total_reviews'] ?? 0),
  countryId: _toInt(json['country_id']),
);

Map<String, dynamic> _$GymToJson(Gym instance) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'description_en': instance.descriptionEn,
  'description_ar': instance.descriptionAr,
  'tier': instance.tier,
  'address': instance.address,
  'lat': instance.lat,
  'lng': instance.lng,
  'phone': instance.phone,
  'logo_url': instance.logoUrl,
  'cover_url': instance.coverUrl,
  'photos': instance.photos,
  'opening_hours': instance.openingHours,
  'amenities': instance.amenities,
  'categories': instance.categories,
  'is_active': instance.isActive,
  'is_featured': instance.isFeatured,
  'rating': instance.rating,
  'total_reviews': instance.totalReviews,
  'country_id': instance.countryId,
};
