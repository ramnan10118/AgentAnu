import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  AuthNotifier() : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = _storage.getToken();
    if (token != null) {
      try {
        final response = await _apiService.getMe();
        if (response['success'] == true) {
          state = state.copyWith(
            user: UserModel.fromJson(response['user']),
            isAuthenticated: true,
          );
        }
      } catch (e) {
        await _storage.clearAll();
      }
    }
  }

  Future<bool> sendOtp(String mobile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.sendOtp(mobile);
      state = state.copyWith(isLoading: false);
      return response['success'] == true;
    } catch (e) {
      print('❌ Send OTP Error: $e');
      final errorMessage = e.toString().contains('Failed host lookup') 
          ? 'Cannot connect to server. Make sure backend is running on http://localhost:3000'
          : e.toString();
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> verifyOtp(String mobile, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.verifyOtp(mobile, otp);
      if (response['success'] == true) {
        await _storage.saveToken(response['token']);
        await _storage.saveUser(response['user']);
        state = state.copyWith(
          user: UserModel.fromJson(response['user']),
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Verification failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> validatePan(String pan) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.validatePan(pan);
      if (response['success'] == true) {
        state = state.copyWith(
          user: UserModel.fromJson(response['user']),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'PAN validation failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      print('Logout error: $e');
    }
    await _storage.clearAll();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

