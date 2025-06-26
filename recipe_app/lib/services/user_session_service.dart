import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/models/user.dart' as AppUser;
import 'package:recipe_app/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Login user using Firebase Authentication
  static Future<bool> loginUser(String email, String password) async {
    try {
      print('🔐 Attempting Firebase Auth login: $email');

      // Sign in with Firebase Auth
      final credential = await FirebaseService.signInWithEmailAndPassword(
        email.trim(),
        password.trim(),
      );

      if (credential != null && credential.user != null) {
        final firebaseUser = credential.user!;
        print('✅ Firebase Auth login successful for: ${firebaseUser.email}');

        // Get user profile from Firestore
        final userProfile = await FirebaseService.getUserById(firebaseUser.uid);

        if (userProfile != null) {
          _currentUser = userProfile;
          await _saveUserIdToPrefs(userProfile.id);
          print('✅ User profile loaded: ${userProfile.name}');
          return true;
        } else {
          // Create user profile if it doesn't exist
          final newUserProfile = AppUser.User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? email,
            bio: 'New Recipe App user',
          );

          final success =
              await FirebaseService.createOrUpdateUser(newUserProfile);
          if (success) {
            _currentUser = newUserProfile;
            await _saveUserIdToPrefs(newUserProfile.id);
            print(
                '✅ User profile created and logged in: ${newUserProfile.name}');
            return true;
          }
        }
      }

      print('❌ Login failed: Invalid credentials or user creation failed');
      return false;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('❌ Error during login: $e');
      return false;
    }
  }

  /// Register new user using Firebase Authentication
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      print('📝 Registering new user with Firebase Auth: $email');

      // Create Firebase Auth account
      final credential = await FirebaseService.signUpWithEmailAndPassword(
        email.trim(),
        password.trim(),
      );

      if (credential != null && credential.user != null) {
        final firebaseUser = credential.user!;
        print('✅ Firebase Auth account created: ${firebaseUser.uid}');

        // Update display name
        await firebaseUser.updateDisplayName(name);

        // Create user profile in Firestore
        final newUser = AppUser.User(
          id: firebaseUser.uid,
          name: name.trim(),
          email: email.trim(),
          phone: phone?.trim(),
          gender: gender,
          dateOfBirth: dateOfBirth,
          bio: 'New Recipe App user',
        );

        // Save to Firestore
        final success = await FirebaseService.createOrUpdateUser(newUser);

        if (success) {
          print('✅ User registered successfully: ${newUser.name}');
          // Don't auto-login after registration for security
          return true;
        } else {
          // If Firestore creation fails, delete the auth account
          await firebaseUser.delete();
          print('❌ Failed to save user profile, Auth account deleted');
          return false;
        }
      }

      print('❌ Registration failed: Firebase Auth account creation failed');
      return false;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Registration Error: ${e.code} - ${e.message}');
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('❌ Error during registration: $e');
      return false;
    }
  }

  /// Logout current user
  static Future<void> logoutUser() async {
    try {
      // Sign out from Firebase Auth
      await FirebaseService.signOut();

      // Clear local session
      _currentUser = null;
      await _clearUserIdFromPrefs();

      print('👋 User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
      // Clear local session even if Firebase logout fails
      _currentUser = null;
      await _clearUserIdFromPrefs();
    }
  }

  /// Load user session from Firebase Auth state
  static Future<bool> loadUserSession() async {
    try {
      // Check if user is signed in with Firebase Auth
      final firebaseUser = FirebaseService.getCurrentAuthUser();

      if (firebaseUser != null) {
        print('🔄 Loading user session for Firebase UID: ${firebaseUser.uid}');

        // Get user profile from Firestore
        final userProfile = await FirebaseService.getUserById(firebaseUser.uid);

        if (userProfile != null) {
          _currentUser = userProfile;
          await _saveUserIdToPrefs(userProfile.id);
          print('✅ User session loaded: ${userProfile.name}');
          return true;
        } else {
          print(
              '❌ User profile not found in Firestore for UID: ${firebaseUser.uid}');
          // Sign out if profile doesn't exist
          await FirebaseService.signOut();
          await _clearUserIdFromPrefs();
        }
      } else {
        print('ℹ️ No Firebase Auth user found');
        await _clearUserIdFromPrefs();
      }

      return false;
    } catch (e) {
      print('❌ Error loading user session: $e');
      return false;
    }
  }

  /// Update current user profile
  static Future<bool> updateUserProfile(AppUser.User updatedUser) async {
    try {
      final success = await FirebaseService.updateUserProfile(updatedUser);

      if (success) {
        _currentUser = updatedUser;

        // Update Firebase Auth profile if needed
        final firebaseUser = FirebaseService.getCurrentAuthUser();
        if (firebaseUser != null) {
          await firebaseUser.updateDisplayName(updatedUser.name);
        }

        print('✅ User profile updated: ${updatedUser.name}');
        return true;
      } else {
        print('❌ Failed to update user profile');
        return false;
      }
    } catch (e) {
      print('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseService.sendPasswordResetEmail(email);
      print('📧 Password reset email sent to: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Error sending password reset email: ${e.code} - ${e.message}');
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      return false;
    }
  }

  /// Update user password
  static Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      // Re-authenticate user first
      await FirebaseService.reauthenticateUser(currentPassword);

      // Update password
      await FirebaseService.updatePassword(newPassword);

      print('🔐 Password updated successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Error updating password: ${e.code} - ${e.message}');
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('❌ Error updating password: $e');
      return false;
    }
  }

  /// Update user email
  static Future<bool> updateEmail(String newEmail, String password) async {
    try {
      // Re-authenticate user first
      await FirebaseService.reauthenticateUser(password);

      // Update email in Firebase Auth
      await FirebaseService.updateEmail(newEmail);

      // Update email in user profile
      if (_currentUser != null) {
        final updatedUser = AppUser.User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: newEmail,
          phone: _currentUser!.phone,
          gender: _currentUser!.gender,
          dateOfBirth: _currentUser!.dateOfBirth,
          bio: _currentUser!.bio,
          profileImageUrl: _currentUser!.profileImageUrl,
        );

        await updateUserProfile(updatedUser);
      }

      print('📧 Email update verification sent successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Error updating email: ${e.code} - ${e.message}');
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('❌ Error updating email: $e');
      return false;
    }
  }

  /// Delete user account
  static Future<bool> deleteUserAccount(String password) async {
    try {
      // Re-authenticate user first
      await FirebaseService.reauthenticateUser(password);

      // Delete Firebase Auth account and Firestore data
      await FirebaseService.deleteUserAccount();

      // Clear local session
      _currentUser = null;
      await _clearUserIdFromPrefs();

      print('🗑️ User account deleted successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Error deleting account: ${e.code} - ${e.message}');
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('❌ Error deleting account: $e');
      return false;
    }
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    final firebaseUser = FirebaseService.getCurrentAuthUser();
    return firebaseUser != null && _currentUser != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _currentUser?.id;
  }

  /// Get Firebase Auth error message for UI display
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'requires-recent-login':
        return 'Please re-authenticate to continue.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  /// Handle Firebase Auth errors
  static void _handleAuthError(FirebaseAuthException e) {
    final message = getAuthErrorMessage(e);
    print('🚨 Auth Error [${e.code}]: $message');
  }

  /// Save user ID to shared preferences
  static Future<void> _saveUserIdToPrefs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
    } catch (e) {
      print('❌ Error saving user ID to preferences: $e');
    }
  }

  /// Clear user ID from shared preferences
  static Future<void> _clearUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
    } catch (e) {
      print('❌ Error clearing user ID from preferences: $e');
    }
  }

  /// Initialize the session service (call this in main.dart)
  static Future<void> initialize() async {
    print('🚀 Initializing UserSessionService...');
    await loadUserSession();
  }
}
