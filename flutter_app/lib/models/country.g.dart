// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  nameEn: json['name_en'] as String,
  nameAr: json['name_ar'] as String,
  currencyCode: json['currency_code'] as String,
  currencySymbolEn: json['currency_symbol_en'] as String,
  currencySymbolAr: json['currency_symbol_ar'] as String,
  vatRate: (json['vat_rate'] as num?)?.toDouble() ?? 0,
  phonePrefix: json['phone_prefix'] as String,
  defaultLang: json['default_lang'] as String? ?? 'ar',
  isActive: json['is_active'] as bool? ?? false,
);

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'currency_code': instance.currencyCode,
  'currency_symbol_en': instance.currencySymbolEn,
  'currency_symbol_ar': instance.currencySymbolAr,
  'vat_rate': instance.vatRate,
  'phone_prefix': instance.phonePrefix,
  'default_lang': instance.defaultLang,
  'is_active': instance.isActive,
};
