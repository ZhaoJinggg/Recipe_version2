import 'package:recipe_app/models/user.dart' as AppUser;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app/services/firebase_service.dart';

class UserSessionService {
  static AppUser.User? _currentUser;
  static const String _userIdKey = 'current_user_id';

  /// Get the currently logged-in user
  static AppUser.User? getCurrentUser() {
    return _currentUser;
  }

  /// Set the current user (called after login/signup)
  static void setCurrentUser(AppUser.User user) {
    _currentUser = user;
    _saveUserIdToPrefs(user.id);
  }

  /// Login user using Firebase Auth
  static Future<bool> loginUser(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await FirebaseService.signInWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        // Fetch user profile from Firestore
        final userProfile = await FirebaseService.getUserById(userCredential.user!.uid);
        if (userProfile != null) {
          _currentUser = userProfile;
          await _saveUserIdToPrefs(userProfile.id);
          print('✅ User profile loaded: \\${userProfile.name}');
          return true;
        } else {
          print('❌ User profile not found in Firestore');
          return false;
        }
      } else {
        print('❌ Firebase Auth sign-in failed');
        return false;
      }
    } catch (e) {
      print('❌ Error during login: $e');
      return false;
    }
  }

  /// Register user using Firebase Auth
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await FirebaseService.createUserWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        // Create user profile in Firestore
        final newUser = AppUser.User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          gender: gender,
          dateOfBirth: dateOfBirth,
          bio: 'Simulated user',
        );
        final success = await FirebaseService.createOrUpdateUser(newUser);
        if (!success) {
          print('❌ Failed to save user to Firestore');
          return false;
        }
        print('✅ Registration for: \\${newUser.email}');
        return true;
      } else {
        print('❌ Firebase Auth registration failed');
        return false;
      }
    } catch (e) {
      print('❌ Error during registration: $e');
      return false;
    }
  }

  /// Logout current user
  static Future<void> logoutUser() async {
    _currentUser = null;
    await _clearUserIdFromPrefs();
    print('👋 Simulated user logged out');
  }

  /// Load user session from Firebase Auth state
  static Future<bool> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    if (userId != null) {
      // Simulate loading user
      _currentUser = AppUser.User(
        id: userId,
        name: userId.split('@').first,
        email: userId,
        bio: 'Simulated user',
      );
      print('✅ Simulated user session loaded: $userId');
      return true;
    }
    return false;
  }

  /// Update current user profile
  static Future<bool> updateUserProfile(AppUser.User updatedUser) async {
    try {
      // Only update local session
      _currentUser = updatedUser;
      print('✅ User profile updated: ${updatedUser.name}');
      return true;
    } catch (e) {
      print('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _currentUser?.id;
  }

  /// Save user ID to shared preferences
  static Future<void> _saveUserIdToPrefs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Clear user ID from shared preferences
  static Future<void> _clearUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  /// Initialize the session service (call this in main.dart)
  static Future<void> initialize() async {
    print('🚀 Initializing UserSessionService...');
    await loadUserSession();
  }
}
