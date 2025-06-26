import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/user.dart' as AppUser;
import 'package:recipe_app/models/post.dart';
import 'package:recipe_app/models/comment.dart';
import 'package:recipe_app/models/grocery_item.dart';
import 'package:recipe_app/models/recipe_rating.dart';
import 'package:recipe_app/models/ingredient.dart';
import 'package:recipe_app/models/tag.dart';
import 'package:recipe_app/models/saved_recipe.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static const String _usersCollection = 'users';
  static const String _recipesCollection = 'recipes';
  static const String _postsCollection = 'posts';
  static const String _commentsCollection = 'comments';
  static const String _groceryListCollection = 'grocery_list';
  static const String _recipeRatingsCollection = 'recipe_ratings';
  static const String _ingredientsCollection = 'ingredients';
  static const String _tagsCollection = 'tags';
  static const String _savedRecipesCollection = 'saved_recipes';
  static const String _recipeIngredientsCollection = 'recipe_ingredients';
  static const String _recipeTagsCollection = 'recipe_tags';

  // Initialize Firebase and check connection
  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp();

      // Test connection to Firestore
      await _firestore.enableNetwork();
      print('✅ Firebase initialized successfully');
      return true;
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      return false;
    }
  }

  // Test Firestore connection
  static Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').doc('connection').get();
      print('✅ Firestore connection successful');
      return true;
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      return false;
    }
  }

  // Enhanced error logging
  static void _logError(String operation, dynamic error) {
    print('❌ Firebase Error [$operation]: $error');
    print('Stack trace: ${StackTrace.current}');
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Sign up with email and password
  static Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      print('📝 Creating Firebase Auth account for: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth account created successfully');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logError('signUpWithEmailAndPassword', e);
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      rethrow;
    } catch (e) {
      _logError('signUpWithEmailAndPassword', e);
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      print('🔐 Signing in with Firebase Auth: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth sign in successful');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logError('signInWithEmailAndPassword', e);
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      rethrow;
    } catch (e) {
      _logError('signInWithEmailAndPassword', e);
      rethrow;
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('👋 User signed out successfully');
    } catch (e) {
      _logError('signOut', e);
      rethrow;
    }
  }

  /// Get current Firebase Auth user
  static User? getCurrentAuthUser() {
    return _auth.currentUser;
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('📧 Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      _logError('sendPasswordResetEmail', e);
      rethrow;
    } catch (e) {
      _logError('sendPasswordResetEmail', e);
      rethrow;
    }
  }

  /// Update password for current user
  static Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        print('🔐 Password updated successfully');
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      _logError('updatePassword', e);
      rethrow;
    } catch (e) {
      _logError('updatePassword', e);
      rethrow;
    }
  }

  /// Update email for current user
  static Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        print('📧 Email update verification sent successfully');
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      _logError('updateEmail', e);
      rethrow;
    } catch (e) {
      _logError('updateEmail', e);
      rethrow;
    }
  }

  /// Re-authenticate user (required for sensitive operations)
  static Future<void> reauthenticateUser(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        print('🔐 User re-authenticated successfully');
      } else {
        throw Exception('No user is currently signed in or email is null');
      }
    } on FirebaseAuthException catch (e) {
      _logError('reauthenticateUser', e);
      rethrow;
    } catch (e) {
      _logError('reauthenticateUser', e);
      rethrow;
    }
  }

  /// Delete user account
  static Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection(_usersCollection).doc(user.uid).delete();

        // Delete Firebase Auth account
        await user.delete();
        print('🗑️ User account deleted successfully');
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      _logError('deleteUserAccount', e);
      rethrow;
    } catch (e) {
      _logError('deleteUserAccount', e);
      rethrow;
    }
  }

  // ==================== USER METHODS ====================

  // Create or update user with enhanced error handling
  static Future<bool> createOrUpdateUser(AppUser.User user) async {
    try {
      print('📝 Creating/Updating user: ${user.id}');

      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));

      print('✅ User ${user.id} saved successfully');
      return true;
    } catch (e) {
      _logError('createOrUpdateUser', e);
      return false;
    }
  }

  // Get user by ID
  static Future<AppUser.User?> getUserById(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return AppUser.User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Get user by email
  static Future<AppUser.User?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AppUser.User.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(AppUser.User user) async {
    return await createOrUpdateUser(user);
  }

  // Update profile image
  static Future<bool> updateProfileImage(
      String userId, String imagePath) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({'profileImageUrl': imagePath});
      return true;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  // ==================== RECIPE METHODS ====================

  // Create recipe
  static Future<String?> createRecipe(Recipe recipe) async {
    try {
      final docRef =
          await _firestore.collection(_recipesCollection).add(recipe.toJson());

      // Update the recipe with the generated ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print('Error creating recipe: $e');
      return null;
    }
  }

  // Get all recipes
  static Future<List<Recipe>> getAllRecipes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_recipesCollection)
          .orderBy('dateCreated', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recipes: $e');
      return [];
    }
  }

  // Get recipes by category
  static Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(_recipesCollection)
          .where('category', isEqualTo: category)
          .orderBy('dateCreated', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recipes by category: $e');
      return [];
    }
  }

  // Get recipe by ID
  static Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final doc =
          await _firestore.collection(_recipesCollection).doc(recipeId).get();

      if (doc.exists && doc.data() != null) {
        return Recipe.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting recipe: $e');
      return null;
    }
  }

  // Get recipes by author
  static Future<List<Recipe>> getRecipesByAuthor(String authorId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_recipesCollection)
          .where('authorId', isEqualTo: authorId)
          .orderBy('dateCreated', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recipes by author: $e');
      return [];
    }
  }

  // Update recipe
  static Future<bool> updateRecipe(Recipe recipe) async {
    try {
      await _firestore
          .collection(_recipesCollection)
          .doc(recipe.id)
          .update(recipe.toJson());
      return true;
    } catch (e) {
      print('Error updating recipe: $e');
      return false;
    }
  }

  // Delete recipe
  static Future<bool> deleteRecipe(String recipeId) async {
    try {
      await _firestore.collection(_recipesCollection).doc(recipeId).delete();
      return true;
    } catch (e) {
      print('Error deleting recipe: $e');
      return false;
    }
  }

  // Search recipes
  static Future<List<Recipe>> searchRecipes(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation. For production, consider using Algolia or similar
      final querySnapshot = await _firestore
          .collection(_recipesCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  // Get daily inspiration recipes (featured recipes)
  static Future<List<Recipe>> getDailyInspirationRecipes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_recipesCollection)
          .where('rating', isGreaterThanOrEqualTo: 4.5)
          .orderBy('rating', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting daily inspiration recipes: $e');
      return [];
    }
  }

  // ==================== POST METHODS ====================

  // Create post
  static Future<String?> createPost(Post post) async {
    try {
      final docRef =
          await _firestore.collection(_postsCollection).add(post.toJson());

      // Update the post with the generated ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Get all posts
  static Future<List<Post>> getAllPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_postsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }

  // Get posts by user
  static Future<List<Post>> getPostsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_postsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting posts by user: $e');
      return [];
    }
  }

  // Update post
  static Future<bool> updatePost(Post post) async {
    try {
      await _firestore
          .collection(_postsCollection)
          .doc(post.id)
          .update(post.toJson());
      return true;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }

  // Delete post
  static Future<bool> deletePost(String postId) async {
    try {
      await _firestore.collection(_postsCollection).doc(postId).delete();
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // ==================== COMMENT METHODS ====================

  // Add comment to recipe
  static Future<String?> addCommentToRecipe(Comment comment) async {
    try {
      final docRef = await _firestore
          .collection(_commentsCollection)
          .add(comment.toJson());

      // Update the comment with the generated ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  // Get comments for recipe
  static Future<List<Comment>> getCommentsForRecipe(String recipeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_commentsCollection)
          .where('recipeId', isEqualTo: recipeId)
          .orderBy('datePosted', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Comment.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // ==================== GROCERY LIST METHODS ====================

  // Add item to grocery list
  static Future<String?> addGroceryItem(GroceryItem item) async {
    try {
      final docRef = await _firestore
          .collection(_groceryListCollection)
          .add(item.toJson());

      // Update the item with the generated ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print('Error adding grocery item: $e');
      return null;
    }
  }

  // Get grocery list for user
  static Future<List<GroceryItem>> getGroceryListForUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_groceryListCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('addedDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => GroceryItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting grocery list: $e');
      return [];
    }
  }

  // Update grocery item
  static Future<bool> updateGroceryItem(GroceryItem item) async {
    try {
      await _firestore
          .collection(_groceryListCollection)
          .doc(item.id)
          .update(item.toJson());
      return true;
    } catch (e) {
      print('Error updating grocery item: $e');
      return false;
    }
  }

  // Delete grocery item
  static Future<bool> deleteGroceryItem(String itemId) async {
    try {
      await _firestore.collection(_groceryListCollection).doc(itemId).delete();
      return true;
    } catch (e) {
      print('Error deleting grocery item: $e');
      return false;
    }
  }

  // ==================== RECIPE RATING METHODS ====================

  // Add or update recipe rating
  static Future<bool> addOrUpdateRecipeRating(RecipeRating rating) async {
    try {
      // Check if rating already exists
      final existingRating = await _firestore
          .collection(_recipeRatingsCollection)
          .where('userId', isEqualTo: rating.userId)
          .where('recipeId', isEqualTo: rating.recipeId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // Update existing rating
        await existingRating.docs.first.reference.update(rating.toJson());
      } else {
        // Create new rating
        final docRef = await _firestore
            .collection(_recipeRatingsCollection)
            .add(rating.toJson());
        await docRef.update({'id': docRef.id});
      }

      // Update recipe's average rating
      await _updateRecipeAverageRating(rating.recipeId);
      return true;
    } catch (e) {
      print('Error adding/updating recipe rating: $e');
      return false;
    }
  }

  // Get ratings for recipe
  static Future<List<RecipeRating>> getRatingsForRecipe(String recipeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_recipeRatingsCollection)
          .where('recipeId', isEqualTo: recipeId)
          .orderBy('dateCreated', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RecipeRating.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recipe ratings: $e');
      return [];
    }
  }

  // Update recipe's average rating
  static Future<void> _updateRecipeAverageRating(String recipeId) async {
    try {
      final ratings = await getRatingsForRecipe(recipeId);
      if (ratings.isNotEmpty) {
        final averageRating =
            ratings.map((r) => r.rating).reduce((a, b) => a + b) /
                ratings.length;

        await _firestore
            .collection(_recipesCollection)
            .doc(recipeId)
            .update({'rating': averageRating});
      }
    } catch (e) {
      print('Error updating recipe average rating: $e');
    }
  }

  // ==================== SAVED RECIPES METHODS ====================

  // Save recipe
  static Future<bool> saveRecipe(String userId, String recipeId) async {
    try {
      final savedRecipe = SavedRecipe(
        id: '',
        userId: userId,
        recipeId: recipeId,
      );

      final docRef = await _firestore
          .collection(_savedRecipesCollection)
          .add(savedRecipe.toJson());
      await docRef.update({'id': docRef.id});
      return true;
    } catch (e) {
      print('Error saving recipe: $e');
      return false;
    }
  }

  // Unsave recipe
  static Future<bool> unsaveRecipe(String userId, String recipeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_savedRecipesCollection)
          .where('userId', isEqualTo: userId)
          .where('recipeId', isEqualTo: recipeId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      print('Error unsaving recipe: $e');
      return false;
    }
  }

  // Get saved recipes for user
  static Future<List<Recipe>> getSavedRecipesForUser(String userId) async {
    try {
      final savedRecipesSnapshot = await _firestore
          .collection(_savedRecipesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final recipeIds = savedRecipesSnapshot.docs
          .map((doc) => SavedRecipe.fromJson(doc.data()).recipeId)
          .toList();

      if (recipeIds.isEmpty) return [];

      // Firestore has a limit of 10 items in 'whereIn' queries
      List<Recipe> allRecipes = [];
      for (int i = 0; i < recipeIds.length; i += 10) {
        final batch = recipeIds.skip(i).take(10).toList();
        final recipesSnapshot = await _firestore
            .collection(_recipesCollection)
            .where('id', whereIn: batch)
            .get();

        final recipes = recipesSnapshot.docs
            .map((doc) => Recipe.fromJson(doc.data()))
            .toList();
        allRecipes.addAll(recipes);
      }

      return allRecipes;
    } catch (e) {
      print('Error getting saved recipes: $e');
      return [];
    }
  }

  // Check if recipe is saved by user
  static Future<bool> isRecipeSavedByUser(
      String userId, String recipeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_savedRecipesCollection)
          .where('userId', isEqualTo: userId)
          .where('recipeId', isEqualTo: recipeId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if recipe is saved: $e');
      return false;
    }
  }

  // ==================== INGREDIENT METHODS ====================

  // Create ingredient
  static Future<String?> createIngredient(Ingredient ingredient) async {
    try {
      final docRef = await _firestore
          .collection(_ingredientsCollection)
          .add(ingredient.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print('Error creating ingredient: $e');
      return null;
    }
  }

  // Get all ingredients
  static Future<List<Ingredient>> getAllIngredients() async {
    try {
      final querySnapshot = await _firestore
          .collection(_ingredientsCollection)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Ingredient.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting ingredients: $e');
      return [];
    }
  }

  // ==================== TAG METHODS ====================

  // Create tag
  static Future<String?> createTag(Tag tag) async {
    try {
      final docRef =
          await _firestore.collection(_tagsCollection).add(tag.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print('Error creating tag: $e');
      return null;
    }
  }

  // Get all tags
  static Future<List<Tag>> getAllTags() async {
    try {
      final querySnapshot =
          await _firestore.collection(_tagsCollection).orderBy('name').get();

      return querySnapshot.docs.map((doc) => Tag.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting tags: $e');
      return [];
    }
  }

  // ==================== UTILITY METHODS ====================

  // Generate a unique ID
  static String generateId() {
    return _firestore.collection('temp').doc().id;
  }

  // Batch operations (for data migration from mock service)
  static Future<bool> initializeWithMockData(
      List<Recipe> recipes, List<AppUser.User> users, List<Post> posts) async {
    try {
      final batch = _firestore.batch();

      // Add recipes
      for (final recipe in recipes) {
        final recipeRef =
            _firestore.collection(_recipesCollection).doc(recipe.id);
        batch.set(recipeRef, recipe.toJson());
      }

      // Add users
      for (final user in users) {
        final userRef = _firestore.collection(_usersCollection).doc(user.id);
        batch.set(userRef, user.toJson());
      }

      // Add posts
      for (final post in posts) {
        final postRef = _firestore.collection(_postsCollection).doc(post.id);
        batch.set(postRef, post.toJson());
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error initializing with mock data: $e');
      return false;
    }
  }
}
