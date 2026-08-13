import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

class AdminUser {
  final String email;
  final String name;
  final String role;
  final String fcmToken;

  AdminUser({
    required this.email,
    required this.name,
    required this.role,
    required this.fcmToken,
  });
}

class AuthState {
  final bool isAuthenticated;
  final AdminUser? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    AdminUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(
          AuthState(
            isAuthenticated: true, // Default auto-authenticated as Admin for seamless demo
            user: AdminUser(
              email: AppConstants.defaultAdminEmail,
              name: 'Admin',
              role: 'System Administrator',
              fcmToken: 'fcm_token_admin_device_001',
            ),
          ),
        );

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
      state = AuthState(
        isAuthenticated: true,
        user: AdminUser(
          email: email.trim(),
          name: 'Admin (${email.split('@').first})',
          role: 'System Administrator',
          fcmToken: 'fcm_token_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid Admin Credentials',
      );
      return false;
    }
  }

  void logout() {
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
