import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_storage_data_source.dart';

/// Modular AuthRepository implementation
/// Decoupled so Firebase Auth, Supabase, or custom OAuth can be injected here
class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageDataSource _localStorage;

  AuthRepositoryImpl(this._localStorage);

  @override
  Future<UserProfile?> getCurrentUser() async {
    final loggedIn = _localStorage.isLoggedIn();
    if (!loggedIn) return null;
    return _localStorage.getUserProfile();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _localStorage.isLoggedIn();
  }

  @override
  Future<UserProfile> loginWithEmail(String email, String password) async {
    // In production, delegate to FirebaseAuth.instance.signInWithEmailAndPassword(...)
    final name = email.split('@').first;
    final profile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.isEmpty ? 'Neo User' : '${name[0].toUpperCase()}${name.substring(1)}',
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
      membershipTier: 'Neo Premium Hi-Fi',
      isSubscribed: true,
    );
    await _localStorage.saveUserProfile(profile);
    await _localStorage.setLoggedIn(true);
    return profile;
  }

  @override
  Future<UserProfile> signUpWithEmail(String name, String email, String password) async {
    final profile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Neo User' : name.trim(),
      email: email.trim(),
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
      membershipTier: 'Neo Premium Hi-Fi',
      isSubscribed: true,
    );
    await _localStorage.saveUserProfile(profile);
    await _localStorage.setLoggedIn(true);
    return profile;
  }

  @override
  Future<void> logout() async {
    await _localStorage.setLoggedIn(false);
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _localStorage.saveUserProfile(profile);
    return profile;
  }
}
