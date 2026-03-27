// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  fullName: json['full_name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  gender: json['gender'] as String?,
  birthDate: json['birth_date'] as String?,
  role: json['role'] as String,
  countryId: (json['country_id'] as num).toInt(),
  preferredLanguage: json['preferred_language'] as String? ?? 'ar',
  themePreference: json['theme_preference'] as String? ?? 'system',
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'email': instance.email,
  'full_name': instance.fullName,
  'avatar_url': instance.avatarUrl,
  'gender': instance.gender,
  'birth_date': instance.birthDate,
  'role': instance.role,
  'country_id': instance.countryId,
  'preferred_language': instance.preferredLanguage,
  'theme_preference': instance.themePreference,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
};
