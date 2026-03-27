import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String phone;
  final String? email;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? gender;
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  final String role;
  @JsonKey(name: 'country_id')
  final int countryId;
  @JsonKey(name: 'preferred_language')
  final String preferredLanguage;
  @JsonKey(name: 'theme_preference')
  final String themePreference;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const User({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    this.avatarUrl,
    this.gender,
    this.birthDate,
    required this.role,
    required this.countryId,
    this.preferredLanguage = 'ar',
    this.themePreference = 'system',
    this.isActive = true,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
