import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../services/storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(StorageService.localStorage);
});

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkCurrentUser();
    return const AuthState(isLoading: true);
  }

  Future<void> _checkCurrentUser() async {
    final repo = ref.read(authRepositoryProvider);
    try {
      final user = await repo.getCurrentUser();
      state = AuthState(user: user, isLoading: false);
    } catch (_) {
      state = const AuthState(user: null, isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await repo.loginWithEmail(email, password);
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await repo.signUpWithEmail(name, email, password);
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState(user: null, isLoading: false);
  }

  Future<void> updateProfile(UserProfile updated) async {
    final repo = ref.read(authRepositoryProvider);
    final saved = await repo.updateProfile(updated);
    state = state.copyWith(user: saved);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
