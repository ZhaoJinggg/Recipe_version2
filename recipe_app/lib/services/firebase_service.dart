import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/user.dart' as AppUser;
import 'package:recipe_app/models/post.dart';
import 'package:recipe_app/models/comment.dart';
import 'package:recipe_app/models/grocery_item.dart';
import 'package:recipe_app/models/recipe_rating.dart';
import 'package:recipe_app/models/ingredient.dart';
import 'package:recipe_app/models/tag.dart';
import 'package:recipe_app/models/saved_recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/services/recipe_tagging_service.dart';

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
      // Use the recipe's id as the document ID to prevent duplicates
      await _firestore
          .collection(_recipesCollection)
          .doc(recipe.id)
          .set(recipe.toJson());
      // Apply dynamic tagging using the new tagging service
      await _applyDynamicTagging(recipe.id, recipe);
      return recipe.id;
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

      // Apply dynamic tagging using the new tagging service
      await _applyDynamicTagging(recipe.id, recipe);

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
      // Simplified duplicate check to avoid composite index requirement
      // Check for duplicate posts (same content by same user within last 5 minutes)
      final fiveMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 5));

      try {
        final duplicateCheck = await _firestore
            .collection(_postsCollection)
            .where('userId', isEqualTo: post.userId)
            .where('content', isEqualTo: post.content)
            .where('createdAt',
                isGreaterThan: fiveMinutesAgo.millisecondsSinceEpoch)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          print('❌ Duplicate post detected. Post not created.');
          return null;
        }
      } catch (e) {
        // If composite index is missing, skip duplicate check for now
        print(
            '⚠️ Composite index missing for duplicate check. Skipping duplicate detection.');
        print(
            '💡 To enable duplicate detection, create this index in Firebase Console:');
        print('   Collection: posts');
        print(
            '   Fields: userId (Ascending), content (Ascending), createdAt (Ascending)');
        print(
            '   Or click this link: https://console.firebase.google.com/v1/r/project/recipe-app-6f86b/firestore/indexes?create_composite=Ck5wcm9qZWN0cy9yZWNpcGUtYXBwLTZmODZiL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9wb3N0cy9pbmRleGVzL18QARoLCgdjb250ZW50EAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAEaDAoIX19uYW1lX18QAQ');
      }

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

  // Create post without duplicate detection (for initial setup)
  static Future<String?> createPostWithoutDuplicateCheck(Post post) async {
    try {
      print('📝 Creating post without duplicate check: ${post.userName}');

      final docRef =
          await _firestore.collection(_postsCollection).add(post.toJson());

      // Update the post with the generated ID
      await docRef.update({'id': docRef.id});
      print('✅ Post created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating post without duplicate check: $e');
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

  // Clean up duplicate posts
  static Future<void> cleanupDuplicatePosts() async {
    try {
      print('🧹 Starting duplicate post cleanup...');

      // Get all posts
      final allPosts = await getAllPosts();
      final Map<String, List<Post>> userContentMap = {};

      // Group posts by user and content
      for (final post in allPosts) {
        final key = '${post.userId}_${post.content}';
        if (!userContentMap.containsKey(key)) {
          userContentMap[key] = [];
        }
        userContentMap[key]!.add(post);
      }

      // Find and delete duplicates (keep the oldest post)
      int deletedCount = 0;
      for (final entry in userContentMap.entries) {
        final posts = entry.value;
        if (posts.length > 1) {
          // Sort by creation time (oldest first)
          posts.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          // Keep the first (oldest) post, delete the rest
          for (int i = 1; i < posts.length; i++) {
            await deletePost(posts[i].id);
            deletedCount++;
            print('🗑️ Deleted duplicate post: ${posts[i].id}');
          }
        }
      }

      print(
          '✅ Duplicate cleanup completed. Deleted $deletedCount duplicate posts.');
    } catch (e) {
      print('❌ Error during duplicate cleanup: $e');
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
      return docRef.id;
    } catch (e) {
      print('Error creating tag: $e');
      return null;
    }
  }

  // Get all tags
  static Future<List<Tag>> getAllTags() async {
    try {
      final querySnapshot = await _firestore
          .collection(_tagsCollection)
          .orderBy('tag_name')
          .get();

      return querySnapshot.docs
          .map((doc) => Tag.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting tags: $e');
      return [];
    }
  }

  // Get tag ID by tag name, create if doesn't exist
  static Future<String?> getOrCreateTagId(String tagName) async {
    try {
      // First, try to find existing tag by name
      final querySnapshot = await _firestore
          .collection(_tagsCollection)
          .where('tag_name', isEqualTo: tagName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Tag exists, return its ID
        return querySnapshot.docs.first.id;
      }

      // Tag doesn't exist, create it
      final newTag = Tag(
        id: '', // Will be auto-generated
        name: tagName,
      );

      final docRef =
          await _firestore.collection(_tagsCollection).add(newTag.toJson());

      print('✅ Created new tag: $tagName with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error getting or creating tag: $e');
      return null;
    }
  }

  // Assign tags to a recipe
  static Future<bool> assignTagsToRecipe(
      String recipeId, List<String> tagNames) async {
    try {
      // Remove existing recipe tags first
      await _removeRecipeTagsForRecipe(recipeId);

      // Get or create tag IDs for each tag name
      for (final tagName in tagNames) {
        final tagId = await getOrCreateTagId(tagName);
        if (tagId != null) {
          // Create recipe-tag relationship
          final recipeTag = RecipeTag(
            id: '', // Will be auto-generated
            recipeId: recipeId,
            tagId: tagId,
          );

          final docRef = await _firestore
              .collection(_recipeTagsCollection)
              .add(recipeTag.toJson());
          await docRef.update({'id': docRef.id});
        } else {
          print('⚠️ Failed to get/create tag ID for: $tagName');
        }
      }

      print(
          '✅ Successfully assigned ${tagNames.length} tags to recipe: $recipeId');
      return true;
    } catch (e) {
      print('Error assigning tags to recipe: $e');
      return false;
    }
  }

  // Helper method to remove existing recipe tags for a recipe
  static Future<void> _removeRecipeTagsForRecipe(String recipeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_recipeTagsCollection)
          .where('recipe_id', isEqualTo: recipeId)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      if (querySnapshot.docs.isNotEmpty) {
        await batch.commit();
        print(
            '🗑️ Removed ${querySnapshot.docs.length} existing recipe tags for recipe: $recipeId');
      }
    } catch (e) {
      print('Error removing recipe tags: $e');
    }
  }

  // Get tag names for a recipe
  static Future<List<String>> getTagNamesForRecipe(String recipeId) async {
    try {
      final recipeTagsSnapshot = await _firestore
          .collection(_recipeTagsCollection)
          .where('recipe_id', isEqualTo: recipeId)
          .get();

      final tagIds = recipeTagsSnapshot.docs
          .map((doc) => RecipeTag.fromJson(doc.data()).tagId)
          .toList();

      if (tagIds.isEmpty) return [];

      // Get tag names for these IDs
      List<String> tagNames = [];
      for (final tagId in tagIds) {
        final tagDoc =
            await _firestore.collection(_tagsCollection).doc(tagId).get();
        if (tagDoc.exists && tagDoc.data() != null) {
          final tag = Tag.fromJson({...tagDoc.data()!, 'id': tagDoc.id});
          tagNames.add(tag.name);
        }
      }

      return tagNames;
    } catch (e) {
      print('Error getting tag names for recipe: $e');
      return [];
    }
  }

  // Get recipes by tag name
  static Future<List<Recipe>> getRecipesByTagName(String tagName) async {
    try {
      // First get the tag ID
      final tagId = await getOrCreateTagId(tagName);
      if (tagId == null) return [];

      // Get recipe IDs that have this tag
      final recipeTagsSnapshot = await _firestore
          .collection(_recipeTagsCollection)
          .where('tag_id', isEqualTo: tagId)
          .get();

      final recipeIds = recipeTagsSnapshot.docs
          .map((doc) => RecipeTag.fromJson(doc.data()).recipeId)
          .toList();

      if (recipeIds.isEmpty) return [];

      // Get recipes for these IDs (handling Firestore's 10-item limit for whereIn)
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
      print('Error getting recipes by tag name: $e');
      return [];
    }
  }

  // ==================== UTILITY METHODS ====================

  // Helper method to apply dynamic tagging to a recipe
  static Future<void> _applyDynamicTagging(
      String recipeId, Recipe recipe) async {
    try {
      // Apply dynamic tagging based on recipe characteristics
      await RecipeTaggingService.applyTagsToRecipe(
        recipeId: recipeId,
        category: recipe.category,
        prepTimeMinutes: recipe.prepTimeMinutes,
        difficultyLevel: recipe.difficultyLevel,
        ingredients: recipe.ingredients,
        title: recipe.title,
        description: recipe.description,
        additionalTags: recipe.tags, // Include any manually set tags
      );
    } catch (e) {
      print('Error applying dynamic tagging: $e');
      // Fallback to manual tag assignment if dynamic tagging fails
      if (recipe.tags.isNotEmpty) {
        await assignTagsToRecipe(recipeId, recipe.tags);
      }
    }
  }

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

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  /// Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Stream<List<Recipe>> streamSavedRecipesForUser(String userId) async* {
    final savedRecipesStream = _firestore
        .collection(_savedRecipesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots();

    await for (final snapshot in savedRecipesStream) {
      final recipeIds = snapshot.docs
          .map((doc) => SavedRecipe.fromJson(doc.data()).recipeId)
          .toList();

      if (recipeIds.isEmpty) {
        yield [];
        continue;
      }

      // Firestore 'whereIn' limit is 10
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
      yield allRecipes;
    }
  }
}
