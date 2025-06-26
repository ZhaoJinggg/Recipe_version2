import 'package:recipe_app/services/firebase_service.dart';

/// Service for dynamic recipe tagging using Firestore
/// Replaces hardcoded tag logic with dynamic database operations
class RecipeTaggingService {
  /// Automatically assign tags to a recipe based on its characteristics
  /// This replaces hardcoded tagging logic with dynamic Firestore operations
  static Future<List<String>> generateTagsForRecipe({
    required String category,
    required int prepTimeMinutes,
    required String? difficultyLevel,
    required List<String> ingredients,
    required String title,
    String? description,
  }) async {
    final tags = <String>[];

    // Category-based tags (always add category)
    if (category.isNotEmpty) {
      tags.add(category);
    }

    // Time-based tags
    if (prepTimeMinutes <= 30) {
      tags.add('Quick');
    }

    // Difficulty tags
    if (difficultyLevel != null && difficultyLevel.isNotEmpty) {
      tags.add(difficultyLevel);
    }

    // Ingredient-based tags (check for common dietary indicators)
    final ingredientList = ingredients.map((i) => i.toLowerCase()).toList();

    if (_containsAny(ingredientList,
        ['chicken', 'beef', 'pork', 'lamb', 'fish', 'salmon', 'tuna'])) {
      // Has meat/fish
    } else if (_containsAny(ingredientList, ['tofu', 'tempeh', 'seitan'])) {
      tags.add('Vegan');
      tags.add('Vegetarian');
    } else if (_containsAny(
        ingredientList, ['cheese', 'milk', 'butter', 'cream', 'egg'])) {
      tags.add('Vegetarian');
    } else {
      // Might be vegan if no obvious animal products
      tags.add('Vegan');
      tags.add('Vegetarian');
    }

    // Seafood detection
    if (_containsAny(ingredientList, [
      'fish',
      'salmon',
      'tuna',
      'shrimp',
      'crab',
      'lobster',
      'prawn',
      'scallop'
    ])) {
      tags.add('Seafood');
    }

    // Spicy detection
    if (_containsAny(ingredientList, [
      'chili',
      'pepper',
      'jalapeño',
      'sriracha',
      'tabasco',
      'curry',
      'paprika',
      'cayenne'
    ])) {
      tags.add('Spicy');
    }

    // Healthy detection
    if (_containsAny(ingredientList, [
      'quinoa',
      'kale',
      'spinach',
      'avocado',
      'chia',
      'salmon',
      'olive oil',
      'nuts'
    ])) {
      tags.add('Healthy');
    }

    // Regional cuisine detection based on ingredients
    if (_containsAny(ingredientList,
        ['soy sauce', 'ginger', 'sesame', 'rice wine', 'bok choy'])) {
      tags.add('Chinese');
    }

    if (_containsAny(
        ingredientList, ['gochujang', 'kimchi', 'korean', 'sesame oil'])) {
      tags.add('Korean');
    }

    if (_containsAny(ingredientList, [
      'basil',
      'oregano',
      'parmesan',
      'mozzarella',
      'olive oil',
      'balsamic'
    ])) {
      tags.add('Italian');
    }

    if (_containsAny(ingredientList,
        ['coconut milk', 'lemongrass', 'fish sauce', 'thai', 'pandan'])) {
      tags.add('Malaysian');
    }

    // Gluten-free detection (basic check)
    if (!_containsAny(ingredientList,
            ['flour', 'wheat', 'pasta', 'bread', 'soy sauce']) &&
        _containsAny(ingredientList, ['rice', 'quinoa', 'gluten-free'])) {
      tags.add('Gluten-Free');
    }

    return tags.toSet().toList(); // Remove duplicates
  }

  /// Check if a list contains any of the specified items
  static bool _containsAny(List<String> list, List<String> targets) {
    return targets.any(
        (target) => list.any((item) => item.contains(target.toLowerCase())));
  }

  /// Apply tags to a recipe using the dynamic tagging system
  static Future<bool> applyTagsToRecipe({
    required String recipeId,
    required String category,
    required int prepTimeMinutes,
    required String? difficultyLevel,
    required List<String> ingredients,
    required String title,
    String? description,
    List<String>? additionalTags,
  }) async {
    try {
      // Generate automatic tags
      final autoTags = await generateTagsForRecipe(
        category: category,
        prepTimeMinutes: prepTimeMinutes,
        difficultyLevel: difficultyLevel,
        ingredients: ingredients,
        title: title,
        description: description,
      );

      // Combine with any additional manual tags
      final allTags = <String>[...autoTags];
      if (additionalTags != null) {
        allTags.addAll(additionalTags);
      }

      // Remove duplicates and assign to recipe
      final uniqueTags = allTags.toSet().toList();
      return await FirebaseService.assignTagsToRecipe(recipeId, uniqueTags);
    } catch (e) {
      print('Error applying tags to recipe: $e');
      return false;
    }
  }

  /// Get popular tag suggestions for UI autocomplete
  static Future<List<String>> getPopularTagSuggestions() async {
    try {
      final allTags = await FirebaseService.getAllTags();
      return allTags.map((tag) => tag.name).toList();
    } catch (e) {
      print('Error getting tag suggestions: $e');
      return _getDefaultTagSuggestions();
    }
  }

  /// Get default tag suggestions as fallback
  static List<String> _getDefaultTagSuggestions() {
    return [
      'Quick',
      'Easy',
      'Healthy',
      'Vegetarian',
      'Vegan',
      'Gluten-Free',
      'Spicy',
      'Seafood',
      'Italian',
      'Chinese',
      'Korean',
      'Malaysian',
      'American',
      'Appetizer',
      'Main Course',
      'Dessert',
      'Breakfast',
    ];
  }

  /// Search recipes by multiple tags
  static Future<List<String>> getRecipeIdsByTags(List<String> tagNames) async {
    try {
      if (tagNames.isEmpty) return [];

      Set<String> recipeIds = {};
      bool firstTag = true;

      for (final tagName in tagNames) {
        final recipesForTag =
            await FirebaseService.getRecipesByTagName(tagName);
        final idsForTag = recipesForTag.map((r) => r.id).toSet();

        if (firstTag) {
          recipeIds = idsForTag;
          firstTag = false;
        } else {
          // Intersection - recipes that have ALL tags
          recipeIds = recipeIds.intersection(idsForTag);
        }

        // If no recipes have all tags so far, no point continuing
        if (recipeIds.isEmpty) break;
      }

      return recipeIds.toList();
    } catch (e) {
      print('Error getting recipes by tags: $e');
      return [];
    }
  }
}
