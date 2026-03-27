import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env.dart';

// Web-safe token storage
class _TokenStore {
  static final _TokenStore _instance = _TokenStore._();
  factory _TokenStore() => _instance;
  _TokenStore._();

  final FlutterSecureStorage? _secure = kIsWeb ? null : const FlutterSecureStorage();
  final Map<String, String> _memStore = {};

  Future<void> write(String key, String value) async {
    if (_secure != null) {
      await _secure.write(key: key, value: value);
    } else {
      _memStore[key] = value;
    }
  }

  Future<String?> read(String key) async {
    if (_secure != null) {
      return await _secure.read(key: key);
    }
    return _memStore[key];
  }

  Future<void> delete(String key) async {
    if (_secure != null) {
      await _secure.delete(key: key);
    } else {
      _memStore.remove(key);
    }
  }
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final _storage = _TokenStore();

  String _countryCode = 'JO';
  String _lang = 'en';

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Auth interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['X-Country-Code'] = _countryCode;
          options.headers['Accept-Language'] = _lang;
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final opts = error.requestOptions;
              final token = await _storage.read('access_token');
              opts.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(opts);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setCountry(String code) => _countryCode = code;
  void setLang(String lang) => _lang = lang;

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write('access_token', access);
    await _storage.write('refresh_token', refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete('access_token');
    await _storage.delete('refresh_token');
  }

  Future<String?> getAccessToken() => _storage.read('access_token');

  Future<bool> _refreshToken() async {
    try {
      final refresh = await _storage.read('refresh_token');
      if (refresh == null) return false;
      final response = await Dio(
        BaseOptions(baseUrl: Env.apiBaseUrl),
      ).post('/auth/refresh', data: {'refresh_token': refresh});
      final newToken = response.data['access_token'] as String;
      await _storage.write('access_token', newToken);
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }
}
