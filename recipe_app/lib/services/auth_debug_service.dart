import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/models/user.dart' as recipe_app;

class AuthDebugService {
  /// Test Firebase Authentication workflow
  static Future<void> testAuthWorkflow() async {
    print('🧪 Starting Firebase Auth Debug Test...');

    try {
      // Test 1: Create a test user
      print('\n📝 Test 1: Creating test user...');
      const testEmail = 'test@recipeapp.com';
      const testPassword = 'testpassword123';
      const testName = 'Test User';

      final registrationSuccess = await UserSessionService.registerUser(
        name: testName,
        email: testEmail,
        password: testPassword,
        phone: '+1234567890',
        gender: 'Other',
        dateOfBirth: '01/01/1990',
      );

      if (registrationSuccess) {
        print('✅ Test user registration: SUCCESS');
      } else {
        print('❌ Test user registration: FAILED');
        return;
      }

      // Test 2: Login with test user
      print('\n🔐 Test 2: Logging in with test user...');
      final loginSuccess =
          await UserSessionService.loginUser(testEmail, testPassword);

      if (loginSuccess) {
        print('✅ Test user login: SUCCESS');
        final currentUser = UserSessionService.getCurrentUser();
        print('   User: ${currentUser?.name} (${currentUser?.email})');
      } else {
        print('❌ Test user login: FAILED');
        return;
      }

      // Test 3: Check authentication state
      print('\n🔍 Test 3: Checking authentication state...');
      final firebaseUser = FirebaseService.getCurrentAuthUser();
      final isLoggedIn = UserSessionService.isLoggedIn();

      print('   Firebase Auth User: ${firebaseUser?.email ?? 'None'}');
      print(
          '   Session Service User: ${UserSessionService.getCurrentUser()?.email ?? 'None'}');
      print('   Is Logged In: $isLoggedIn');

      if (firebaseUser != null && isLoggedIn) {
        print('✅ Authentication state: CONSISTENT');
      } else {
        print('❌ Authentication state: INCONSISTENT');
      }

      // Test 4: Password reset
      print('\n📧 Test 4: Testing password reset...');
      final resetSuccess =
          await UserSessionService.sendPasswordResetEmail(testEmail);

      if (resetSuccess) {
        print('✅ Password reset email: SUCCESS');
      } else {
        print('❌ Password reset email: FAILED');
      }

      // Test 5: Logout
      print('\n👋 Test 5: Testing logout...');
      await UserSessionService.logoutUser();

      final loggedInAfterLogout = UserSessionService.isLoggedIn();
      final firebaseUserAfterLogout = FirebaseService.getCurrentAuthUser();

      if (!loggedInAfterLogout && firebaseUserAfterLogout == null) {
        print('✅ Logout: SUCCESS');
      } else {
        print('❌ Logout: FAILED');
        print('   Still logged in: $loggedInAfterLogout');
        print('   Firebase user exists: ${firebaseUserAfterLogout != null}');
      }

      // Clean up: Delete test user
      print('\n🗑️ Cleanup: Attempting to delete test user...');
      try {
        // Login again to delete
        await UserSessionService.loginUser(testEmail, testPassword);
        final deleteSuccess =
            await UserSessionService.deleteUserAccount(testPassword);

        if (deleteSuccess) {
          print('✅ Test user cleanup: SUCCESS');
        } else {
          print('❌ Test user cleanup: FAILED');
        }
      } catch (e) {
        print('⚠️ Test user cleanup: ${e.toString()}');
      }

      print('\n🎉 Firebase Auth Debug Test Completed!');
    } catch (e) {
      print('❌ Auth Debug Test Error: $e');
    }
  }

  /// Test error handling scenarios
  static Future<void> testErrorHandling() async {
    print('🧪 Starting Firebase Auth Error Handling Test...');

    try {
      // Test 1: Invalid email login
      print('\n📝 Test 1: Testing invalid email login...');
      final invalidEmailResult = await UserSessionService.loginUser(
          'invalid-email-format', 'anypassword');
      print(
          '   Invalid email login result: $invalidEmailResult (should be false)');

      // Test 2: Non-existent user login
      print('\n📝 Test 2: Testing non-existent user login...');
      final nonExistentResult = await UserSessionService.loginUser(
          'nonexistent@example.com', 'anypassword');
      print(
          '   Non-existent user login result: $nonExistentResult (should be false)');

      // Test 3: Weak password registration
      print('\n📝 Test 3: Testing weak password registration...');
      final weakPasswordResult = await UserSessionService.registerUser(
        name: 'Test User',
        email: 'weakpass@example.com',
        password: '123',
      );
      print(
          '   Weak password registration result: $weakPasswordResult (should be false)');

      // Test 4: Duplicate email registration
      print('\n📝 Test 4: Testing duplicate email registration...');
      // First create a user
      const testEmail = 'duplicate@test.com';
      const testPassword = 'validpassword123';

      await UserSessionService.registerUser(
        name: 'First User',
        email: testEmail,
        password: testPassword,
      );

      // Try to create another with same email
      final duplicateResult = await UserSessionService.registerUser(
        name: 'Second User',
        email: testEmail,
        password: testPassword,
      );
      print(
          '   Duplicate email registration result: $duplicateResult (should be false)');

      // Clean up
      try {
        await UserSessionService.loginUser(testEmail, testPassword);
        await UserSessionService.deleteUserAccount(testPassword);
      } catch (e) {
        print('   Cleanup error: $e');
      }

      print('\n🎉 Error Handling Test Completed!');
    } catch (e) {
      print('❌ Error Handling Test Error: $e');
    }
  }

  /// Print current authentication status
  static void printAuthStatus() {
    print('\n📊 Current Authentication Status:');
    print('════════════════════════════════════');

    final firebaseUser = FirebaseService.getCurrentAuthUser();
    final sessionUser = UserSessionService.getCurrentUser();
    final isLoggedIn = UserSessionService.isLoggedIn();

    print('Firebase Auth User:');
    if (firebaseUser != null) {
      print('  ✅ Signed in as: ${firebaseUser.email}');
      print('  📧 Email verified: ${firebaseUser.emailVerified}');
      print('  🆔 UID: ${firebaseUser.uid}');
      print('  👤 Display name: ${firebaseUser.displayName ?? 'Not set'}');
    } else {
      print('  ❌ Not signed in');
    }

    print('\nSession Service User:');
    if (sessionUser != null) {
      print('  ✅ Logged in as: ${sessionUser.name}');
      print('  📧 Email: ${sessionUser.email}');
      print('  🆔 ID: ${sessionUser.id}');
      print('  📱 Phone: ${sessionUser.phone ?? 'Not set'}');
    } else {
      print('  ❌ No session user');
    }

    print('\nOverall Status:');
    print('  🔐 Is Logged In: $isLoggedIn');
    print(
        '  🔄 State Consistent: ${(firebaseUser != null) == (sessionUser != null)}');

    print('════════════════════════════════════\n');
  }

  /// Test Firebase connection and configuration
  static Future<void> testFirebaseConnection() async {
    print('🧪 Testing Firebase Connection...');

    try {
      // Test Firestore connection
      final firestoreConnected = await FirebaseService.testConnection();
      print(
          '🔥 Firestore connection: ${firestoreConnected ? "SUCCESS" : "FAILED"}');

      // Test Auth service
      final authInstance = FirebaseAuth.instance;
      print('🔐 Firebase Auth instance: ${authInstance.app.name}');
      print('🌐 Current user: ${authInstance.currentUser?.email ?? "None"}');

      // Test creating a test document
      print('📝 Testing Firestore write access...');
      final testDoc = {
        'test': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // This will test write permissions
      await FirebaseService.createOrUpdateUser(
        recipe_app.User(
          id: 'test_connection_user',
          name: 'Test Connection',
          email: 'test@connection.com',
          bio: 'Connection test user',
        ),
      );

      print('✅ Firestore write access: SUCCESS');
    } catch (e) {
      print('❌ Firebase connection test failed: $e');
    }
  }
}
