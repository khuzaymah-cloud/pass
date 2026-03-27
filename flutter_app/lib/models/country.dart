import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  final int id;
  final String code;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  @JsonKey(name: 'currency_code')
  final String currencyCode;
  @JsonKey(name: 'currency_symbol_en')
  final String currencySymbolEn;
  @JsonKey(name: 'currency_symbol_ar')
  final String currencySymbolAr;
  @JsonKey(name: 'vat_rate')
  final double vatRate;
  @JsonKey(name: 'phone_prefix')
  final String phonePrefix;
  @JsonKey(name: 'default_lang')
  final String defaultLang;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const Country({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.currencyCode,
    required this.currencySymbolEn,
    required this.currencySymbolAr,
    this.vatRate = 0,
    required this.phonePrefix,
    this.defaultLang = 'ar',
    this.isActive = false,
  });

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String currencySymbol(String lang) =>
      lang == 'ar' ? currencySymbolAr : currencySymbolEn;

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
