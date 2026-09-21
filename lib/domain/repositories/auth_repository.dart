import '../models/user_profile.dart';

/// Abstract Auth Repository Contract
/// Ready for Firebase, Supabase, OAuth, or custom JWT authentication
abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<UserProfile> loginWithEmail(String email, String password);
  Future<UserProfile> signUpWithEmail(String name, String email, String password);
  Future<void> logout();
  Future<UserProfile> updateProfile(UserProfile profile);
}
