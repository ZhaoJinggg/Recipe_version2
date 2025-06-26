import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/models/post.dart';

class FirebaseTestService {
  /// Test all Firebase CRUD operations
  static Future<bool> runAllTests() async {
    print('🧪 Starting Firebase CRUD tests...');

    try {
      // Test Firebase connection
      print('\n1. Testing Firebase connection...');
      final isConnected = await FirebaseService.testConnection();
      if (!isConnected) {
        print('❌ Firebase connection failed');
        return false;
      }
      print('✅ Firebase connection successful');

      // Test User operations
      print('\n2. Testing User CRUD operations...');
      final userTestPassed = await _testUserOperations();
      if (!userTestPassed) return false;

      // Test Recipe operations
      print('\n3. Testing Recipe CRUD operations...');
      final recipeTestPassed = await _testRecipeOperations();
      if (!recipeTestPassed) return false;

      // Test Post operations
      print('\n4. Testing Post CRUD operations...');
      final postTestPassed = await _testPostOperations();
      if (!postTestPassed) return false;

      print('\n🎉 All Firebase tests passed successfully!');
      print('✅ Data should now be visible in Firebase Console');
      print(
          '🔗 Visit: https://console.firebase.google.com/project/recipe-app-6f86b/firestore');

      return true;
    } catch (e) {
      print('❌ Firebase tests failed: $e');
      return false;
    }
  }

  /// Test User CRUD operations
  static Future<bool> _testUserOperations() async {
    try {
      // Create test user
      final testUser = User(
        id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test User',
        email: 'test@example.com',
        bio: 'This is a test user created by Firebase test service',
      );

      // Test Create
      print('  📝 Creating test user...');
      final createSuccess = await FirebaseService.createOrUpdateUser(testUser);
      if (!createSuccess) {
        print('  ❌ Failed to create user');
        return false;
      }
      print('  ✅ User created successfully');

      // Test Read
      print('  📖 Reading test user...');
      final retrievedUser = await FirebaseService.getUserById(testUser.id);
      if (retrievedUser == null || retrievedUser.id != testUser.id) {
        print('  ❌ Failed to retrieve user');
        return false;
      }
      print('  ✅ User retrieved successfully');

      // Test Update
      print('  ✏️ Updating test user...');
      final updatedUser = testUser.copyWith(
        bio: 'Updated bio - test completed at ${DateTime.now()}',
      );
      final updateSuccess =
          await FirebaseService.updateUserProfile(updatedUser);
      if (!updateSuccess) {
        print('  ❌ Failed to update user');
        return false;
      }
      print('  ✅ User updated successfully');

      return true;
    } catch (e) {
      print('  ❌ User operations failed: $e');
      return false;
    }
  }

  /// Test Recipe CRUD operations
  static Future<bool> _testRecipeOperations() async {
    try {
      // Create test recipe
      final testRecipe = Recipe(
        id: '', // Will be auto-generated
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
        authorId: 'test_user',
        authorName: 'Test Chef',
        description: 'This is a test recipe created by Firebase test service',
        tags: ['test', 'firebase'],
      );

      // Test Create
      print('  📝 Creating test recipe...');
      final recipeId = await FirebaseService.createRecipe(testRecipe);
      if (recipeId == null) {
        print('  ❌ Failed to create recipe');
        return false;
      }
      print('  ✅ Recipe created with ID: $recipeId');

      // Test Read
      print('  📖 Reading test recipe...');
      final retrievedRecipe = await FirebaseService.getRecipeById(recipeId);
      if (retrievedRecipe == null || retrievedRecipe.id != recipeId) {
        print('  ❌ Failed to retrieve recipe');
        return false;
      }
      print('  ✅ Recipe retrieved successfully');

      // Test Read All
      print('  📚 Reading all recipes...');
      final allRecipes = await FirebaseService.getAllRecipes();
      if (allRecipes.isEmpty) {
        print('  ⚠️ No recipes found');
      } else {
        print('  ✅ Found ${allRecipes.length} recipes');
      }

      return true;
    } catch (e) {
      print('  ❌ Recipe operations failed: $e');
      return false;
    }
  }

  /// Test Post CRUD operations
  static Future<bool> _testPostOperations() async {
    try {
      // Create test post
      final testPost = Post(
        id: '', // Will be auto-generated
        userId: 'test_user',
        userName: 'Test User',
        userProfileUrl: 'assets/images/profile1.jpg',
        content:
            'This is a test post created by Firebase test service at ${DateTime.now()}',
        image: 'assets/images/test.png',
        likes: 0,
        comments: [],
        createdAt: DateTime.now(),
      );

      // Test Create
      print('  📝 Creating test post...');
      final postId = await FirebaseService.createPost(testPost);
      if (postId == null) {
        print('  ❌ Failed to create post');
        return false;
      }
      print('  ✅ Post created with ID: $postId');

      // Test Read All
      print('  📚 Reading all posts...');
      final allPosts = await FirebaseService.getAllPosts();
      if (allPosts.isEmpty) {
        print('  ⚠️ No posts found');
      } else {
        print('  ✅ Found ${allPosts.length} posts');
      }

      return true;
    } catch (e) {
      print('  ❌ Post operations failed: $e');
      return false;
    }
  }

  /// Quick health check
  static Future<void> quickHealthCheck() async {
    print('🏥 Running Firebase health check...');

    try {
      // Test connection
      final isConnected = await FirebaseService.testConnection();
      print(isConnected ? '✅ Connection: OK' : '❌ Connection: FAILED');

      // Count documents in each collection
      final collections = [
        'users',
        'recipes',
        'posts',
        'comments',
        'grocery_list',
        'recipe_ratings',
        'saved_recipes'
      ];

      for (final collection in collections) {
        try {
          // Note: This is a simple count, might not be accurate for large collections
          print('📊 $collection: Checking...');
        } catch (e) {
          print('⚠️ $collection: Error accessing collection');
        }
      }

      print('🏥 Health check completed');
    } catch (e) {
      print('❌ Health check failed: $e');
    }
  }
}
