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

  /// Login user using Firebase Auth with account lockout protection
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    try {
      // Check if account is locked, but don't prevent login attempt
      // (Firebase Auth will handle password validation, and successful auth means password was reset)
      final isLocked = await FirebaseService.isAccountLocked(email);

      // Attempt to sign in with Firebase Auth regardless of our lock status
      // If Firebase allows login, it means the password is correct (possibly after reset)
      final userCredential =
          await FirebaseService.signInWithEmailAndPassword(email, password);

      if (userCredential.user != null) {
        // Fetch user profile from Firestore
        final userProfile =
            await FirebaseService.getUserById(userCredential.user!.uid);
        if (userProfile != null) {
          _currentUser = userProfile;
          await _saveUserIdToPrefs(userProfile.id);

          // Reset failed login attempts on successful login
          // This also unlocks the account if it was locked
          await FirebaseService.resetFailedLoginAttempts(userProfile.id);

          // Show special message if account was previously locked
          final message = isLocked
              ? 'Welcome back! Your account has been successfully unlocked.'
              : 'Login successful';

          print('✅ User profile loaded: ${userProfile.name}');
          return {
            'success': true,
            'message': message,
            'wasLocked': isLocked,
          };
        } else {
          print('❌ User profile not found in Firestore');
          return {
            'success': false,
            'error': 'profile_not_found',
            'message': 'User profile not found. Please contact support.',
          };
        }
      } else {
        // This shouldn't happen with Firebase Auth, but handle it just in case
        if (isLocked) {
          return {
            'success': false,
            'error': 'account_locked',
            'message':
                'Account is locked due to too many failed login attempts. Please reset your password via email.',
          };
        }

        await FirebaseService.recordFailedLoginAttempt(email);
        final remainingAttempts =
            await FirebaseService.getRemainingLoginAttempts(email);

        return {
          'success': false,
          'error': 'auth_failed',
          'message': 'Authentication failed',
          'remainingAttempts': remainingAttempts,
        };
      }
    } catch (e) {
      print('❌ Error during login: $e');

      // Check if account was locked before this attempt
      final wasLocked = await FirebaseService.isAccountLocked(email);

      // If account was already locked, show lockout message instead of tracking more attempts
      if (wasLocked) {
        return {
          'success': false,
          'error': 'account_locked',
          'message':
              'Account is locked due to too many failed login attempts. Please reset your password via email.',
        };
      }

      // Record failed attempt for authentication errors (wrong password, etc.)
      if (e.toString().contains('wrong-password') ||
          e.toString().contains('user-not-found') ||
          e.toString().contains('invalid-credential')) {
        await FirebaseService.recordFailedLoginAttempt(email);
        final remainingAttempts =
            await FirebaseService.getRemainingLoginAttempts(email);

        // Check if account is now locked after this attempt
        final isNowLocked = await FirebaseService.isAccountLocked(email);
        if (isNowLocked) {
          return {
            'success': false,
            'error': 'account_locked',
            'message':
                'Account has been locked due to too many failed login attempts. Please reset your password via email.',
          };
        }

        return {
          'success': false,
          'error': 'invalid_credentials',
          'message':
              'Invalid email or password. You have $remainingAttempts attempt(s) remaining.',
          'remainingAttempts': remainingAttempts,
        };
      }

      // For other errors (network, etc.), don't count as failed attempt
      return {
        'success': false,
        'error': 'unknown',
        'message': 'An unexpected error occurred. Please try again.',
      };
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
      final userCredential =
          await FirebaseService.createUserWithEmailAndPassword(email, password);
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

  /// Delete user account and all associated data
  static Future<bool> deleteUserAccount() async {
    try {
      if (_currentUser == null) {
        print('❌ No current user to delete');
        return false;
      }

      print('🗑️ Deleting user account: ${_currentUser!.name}');

      // Delete user from Firebase
      final success = await FirebaseService.deleteUser(_currentUser!.id);
      if (!success) {
        print('❌ Failed to delete user from Firebase');
        return false;
      }

      // Clear local session
      _currentUser = null;
      await _clearUserIdFromPrefs();

      print('✅ User account deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting user account: $e');
      return false;
    }
  }

  /// Change user password
  static Future<bool> changePassword(String newPassword) async {
    try {
      if (_currentUser == null) {
        print('❌ No current user to change password for');
        return false;
      }

      print('🔐 Changing password for user: ${_currentUser!.name}');

      // Change password in Firebase
      final success = await FirebaseService.changePassword(newPassword);
      if (!success) {
        print('❌ Failed to change password in Firebase');
        return false;
      }

      print('✅ Password changed successfully');
      return true;
    } catch (e) {
      print('❌ Error changing password: $e');
      return false;
    }
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
      print('📝 Updating user profile in database: ${updatedUser.name}');

      // Save to Firebase database
      final success = await FirebaseService.createOrUpdateUser(updatedUser);
      if (!success) {
        print('❌ Failed to update user profile in database');
        return false;
      }

      // Update local session
      _currentUser = updatedUser;
      print('✅ User profile updated successfully: ${updatedUser.name}');
      return true;
    } catch (e) {
      print('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Reload current user profile from database
  static Future<bool> reloadUserProfile() async {
    try {
      if (_currentUser == null) {
        print('❌ No current user to reload');
        return false;
      }

      print('🔄 Reloading user profile from database: ${_currentUser!.id}');

      // Fetch latest user data from database
      final userProfile = await FirebaseService.getUserById(_currentUser!.id);
      if (userProfile != null) {
        _currentUser = userProfile;
        print('✅ User profile reloaded successfully: ${userProfile.name}');
        return true;
      } else {
        print('❌ User profile not found in database');
        return false;
      }
    } catch (e) {
      print('❌ Error reloading user profile: $e');
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

  /// Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      print('📧 Sending password reset email to: $email');
      final success = await FirebaseService.sendPasswordResetEmail(email);
      if (success) {
        print('✅ Password reset email sent successfully');
      }
      return success;
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      return false;
    }
  }

  /// Check if account is locked
  static Future<bool> isAccountLocked(String email) async {
    return await FirebaseService.isAccountLocked(email);
  }

  /// Get remaining login attempts for an email
  static Future<int> getRemainingLoginAttempts(String email) async {
    return await FirebaseService.getRemainingLoginAttempts(email);
  }
}
