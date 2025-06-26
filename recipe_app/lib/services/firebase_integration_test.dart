import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/models/recipe.dart';

class FirebaseIntegrationTest {
  /// Test the complete user registration and recipe saving workflow
  static Future<bool> testCompleteWorkflow() async {
    print('🧪 Starting complete Firebase integration test...');

    try {
      // Test 1: User Registration
      print('\n1️⃣ Testing User Registration...');
      final registrationSuccess = await _testUserRegistration();
      if (!registrationSuccess) {
        print('❌ User registration test failed');
        return false;
      }

      // Test 2: User Login
      print('\n2️⃣ Testing User Login...');
      final loginSuccess = await _testUserLogin();
      if (!loginSuccess) {
        print('❌ User login test failed');
        return false;
      }

      // Test 3: Recipe Saving
      print('\n3️⃣ Testing Recipe Saving...');
      final recipeSaveSuccess = await _testRecipeSaving();
      if (!recipeSaveSuccess) {
        print('❌ Recipe saving test failed');
        return false;
      }

      // Test 4: Verify Data in Firebase
      print('\n4️⃣ Verifying Data in Firebase Console...');
      final verificationSuccess = await _verifyDataInFirebase();
      if (!verificationSuccess) {
        print('❌ Data verification test failed');
        return false;
      }

      print('\n🎉 All Firebase integration tests passed successfully!');
      print('✅ User registration: Working');
      print('✅ User login: Working');
      print('✅ Recipe saving: Working');
      print('✅ Data appears in Firebase Console: Working');
      print(
          '\n🔗 Check Firebase Console: https://console.firebase.google.com/project/recipe-app-6f86b/firestore');

      return true;
    } catch (e) {
      print('❌ Firebase integration test failed: $e');
      return false;
    }
  }

  /// Test user registration workflow
  static Future<bool> _testUserRegistration() async {
    try {
      final testEmail =
          'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      final testName = 'Test User ${DateTime.now().millisecondsSinceEpoch}';

      print('  📝 Registering user: $testEmail');

      final success = await UserSessionService.registerUser(
        name: testName,
        email: testEmail,
        password: 'testpassword123',
        phone: '+1234567890',
        gender: 'Other',
        dateOfBirth: '1/1/1990',
      );

      if (success) {
        print('  ✅ User registration successful');

        // Verify user is logged in
        final currentUser = UserSessionService.getCurrentUser();
        if (currentUser != null) {
          print('  ✅ User is properly logged in: ${currentUser.name}');
          return true;
        } else {
          print('  ❌ User registration succeeded but not logged in');
          return false;
        }
      } else {
        print('  ❌ User registration failed');
        return false;
      }
    } catch (e) {
      print('  ❌ Error during user registration test: $e');
      return false;
    }
  }

  /// Test user login workflow
  static Future<bool> _testUserLogin() async {
    try {
      final currentUser = UserSessionService.getCurrentUser();
      if (currentUser == null) {
        print('  ❌ No user available for login test');
        return false;
      }

      print('  🔐 Testing login for: ${currentUser.email}');

      // Logout first
      await UserSessionService.logoutUser();

      // Then login again
      final loginSuccess = await UserSessionService.loginUser(
        currentUser.email,
        'testpassword123',
      );

      if (loginSuccess) {
        print('  ✅ User login successful');
        return true;
      } else {
        print('  ❌ User login failed');
        return false;
      }
    } catch (e) {
      print('  ❌ Error during user login test: $e');
      return false;
    }
  }

  /// Test recipe saving workflow
  static Future<bool> _testRecipeSaving() async {
    try {
      final currentUser = UserSessionService.getCurrentUser();
      if (currentUser == null) {
        print('  ❌ No user logged in for recipe saving test');
        return false;
      }

      // Create a test recipe
      final testRecipe = Recipe(
        id: '',
        title: 'Test Recipe ${DateTime.now().millisecondsSinceEpoch}',
        category: 'Test Category',
        image: 'assets/images/test.png',
        rating: 4.5,
        prepTimeMinutes: 30,
        servings: 4,
        calories: 350,
        ingredients: ['Test ingredient 1', 'Test ingredient 2'],
        directions: ['Test step 1', 'Test step 2'],
        nutritions: ['Test nutrition info'],
        authorId: currentUser.id,
        authorName: currentUser.name,
        description: 'This is a test recipe for Firebase integration',
        tags: ['test', 'integration'],
      );

      print('  📝 Creating test recipe...');
      final recipeId = await FirebaseService.createRecipe(testRecipe);

      if (recipeId != null) {
        print('  ✅ Recipe created with ID: $recipeId');

        // Test saving the recipe to favorites
        print('  💖 Adding recipe to favorites...');
        final saveSuccess =
            await FirebaseService.saveRecipe(currentUser.id, recipeId);

        if (saveSuccess) {
          print('  ✅ Recipe saved to favorites successfully');

          // Verify it's saved
          final isSaved = await FirebaseService.isRecipeSavedByUser(
              currentUser.id, recipeId);
          if (isSaved) {
            print('  ✅ Recipe favorite status verified');
            return true;
          } else {
            print('  ❌ Recipe not found in saved recipes');
            return false;
          }
        } else {
          print('  ❌ Failed to save recipe to favorites');
          return false;
        }
      } else {
        print('  ❌ Failed to create recipe');
        return false;
      }
    } catch (e) {
      print('  ❌ Error during recipe saving test: $e');
      return false;
    }
  }

  /// Verify data exists in Firebase
  static Future<bool> _verifyDataInFirebase() async {
    try {
      print('  🔍 Verifying data in Firebase collections...');

      // Check users collection
      final currentUser = UserSessionService.getCurrentUser();
      if (currentUser != null) {
        final userFromDb = await FirebaseService.getUserById(currentUser.id);
        if (userFromDb != null) {
          print('  ✅ User found in Firebase: ${userFromDb.name}');
        } else {
          print('  ❌ User not found in Firebase');
          return false;
        }
      }

      // Check recipes collection
      final allRecipes = await FirebaseService.getAllRecipes();
      if (allRecipes.isNotEmpty) {
        print('  ✅ Found ${allRecipes.length} recipes in Firebase');
      } else {
        print('  ⚠️ No recipes found in Firebase');
      }

      // Check saved recipes collection
      if (currentUser != null) {
        final savedRecipes =
            await FirebaseService.getSavedRecipesForUser(currentUser.id);
        if (savedRecipes.isNotEmpty) {
          print('  ✅ Found ${savedRecipes.length} saved recipes for user');
        } else {
          print('  ⚠️ No saved recipes found for user');
        }
      }

      print('  ✅ Data verification completed');
      return true;
    } catch (e) {
      print('  ❌ Error during data verification: $e');
      return false;
    }
  }

  /// Quick verification that Firebase connection is working
  static Future<bool> quickFirebaseCheck() async {
    print('🏥 Running quick Firebase connection check...');

    try {
      final isConnected = await FirebaseService.testConnection();
      if (isConnected) {
        print('✅ Firebase connection: OK');
        return true;
      } else {
        print('❌ Firebase connection: FAILED');
        return false;
      }
    } catch (e) {
      print('❌ Firebase connection error: $e');
      return false;
    }
  }
}
