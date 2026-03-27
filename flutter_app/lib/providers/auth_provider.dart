import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) => AuthState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
      return AuthNotifier();
    });

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final _service = AuthService();

  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final loggedIn = await _service.isLoggedIn();
    if (loggedIn) {
      try {
        final user = await _service.getMe();
        state = AsyncValue.data(AuthState(user: user));
      } catch (_) {
        state = const AsyncValue.data(AuthState());
      }
    } else {
      state = const AsyncValue.data(AuthState());
    }
  }

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    return await _service.sendOtp(phone);
  }

  Future<bool> verifyOtp(String phone, String code) async {
    state = const AsyncValue.data(AuthState(isLoading: true));
    try {
      final data = await _service.verifyOtp(phone, code);
      final isNew = data['is_new_user'] as bool;
      if (!isNew && data['user'] != null) {
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        state = AsyncValue.data(AuthState(user: user));
      } else {
        // Fetch user profile after login
        final user = await _service.getMe();
        state = AsyncValue.data(AuthState(user: user));
      }
      return isNew;
    } catch (e) {
      state = AsyncValue.data(AuthState(error: e.toString()));
      rethrow;
    }
  }

  Future<void> register({
    required String fullName,
    String? email,
    String? gender,
    String? birthDate,
  }) async {
    final user = await _service.register(
      fullName: fullName,
      email: email,
      gender: gender,
      birthDate: birthDate,
    );
    state = AsyncValue.data(AuthState(user: user));
  }

  Future<void> refreshUser() async {
    final user = await _service.getMe();
    state = AsyncValue.data(AuthState(user: user));
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AsyncValue.data(AuthState());
  }
}
