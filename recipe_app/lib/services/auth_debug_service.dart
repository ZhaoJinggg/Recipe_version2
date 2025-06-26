import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/models/user.dart' as recipe_app;

class AuthDebugService {
  /// Test Simulated Auth Workflow
  static Future<void> testAuthWorkflow() async {
    print('🧪 Starting Simulated Auth Debug Test...');

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

      // Test 3: Check session state
      print('\n🔍 Test 3: Checking session state...');
      final sessionUser = UserSessionService.getCurrentUser();
      final isLoggedIn = sessionUser != null;

      print('   Session Service User: ${sessionUser?.email ?? 'None'}');
      print('   Is Logged In: $isLoggedIn');
      print('✅ Session state: ${isLoggedIn ? 'ACTIVE' : 'INACTIVE'}');

      // Test 4: Logout
      print('\n👋 Test 4: Testing logout...');
      await UserSessionService.logoutUser();

      final loggedInAfterLogout = UserSessionService.getCurrentUser() != null;
      print('   Still logged in: $loggedInAfterLogout');
      print(
          '${!loggedInAfterLogout ? '✅ Logout: SUCCESS' : '❌ Logout: FAILED'}');

      print('\n🎉 Simulated Auth Debug Test Completed!');
    } catch (e) {
      print('❌ Auth Debug Test Error: $e');
    }
  }

  /// Print current session status
  static void printAuthStatus() {
    print('\n📊 Current Session Status:');
    print('══════════════════════════════════════════════════════════');
    final sessionUser = UserSessionService.getCurrentUser();
    final isLoggedIn = sessionUser != null;
    print('Session Service User:');
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
    print('══════════════════════════════════════════════════════════\n');
  }
}
