import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/recipe_tagging_service.dart';
import 'package:recipe_app/models/recipe.dart';

/// Example service demonstrating how to use the new dynamic recipe tagging system
class ExampleTaggingUsageService {
  
  /// Example: Creating a recipe with automatic intelligent tagging
  static Future<String?> createRecipeWithAutoTagging() async {
    final recipe = Recipe(
      id: '',
      title: 'Spicy Thai Basil Chicken',
      category: 'Main Course',
      image: 'assets/images/thai_basil_chicken.png',
      rating: 0.0,
      prepTimeMinutes: 25, // → Will add 'Quick' tag
      servings: 4,
      calories: 320,
      ingredients: [
        '500g chicken breast',
        '2 tbsp fish sauce', // → Will add 'Thai' tags
        '2 thai chilies', // → Will add 'Spicy' tag
        'Fresh thai basil',
      ],
      directions: ['Cook chicken', 'Add sauces', 'Serve'],
      nutritions: ['Fat: 12g', 'Protein: 35g'],
      authorId: 'current_user',
      authorName: 'Chef Example',
      difficultyLevel: 'Easy', // → Will add 'Easy' tag
      tags: [], // No hardcoded tags needed!
    );

    // The system automatically generates and assigns intelligent tags
    final recipeId = await FirebaseService.createRecipe(recipe);
    
    if (recipeId != null) {
      final assignedTags = await FirebaseService.getTagNamesForRecipe(recipeId);
      print('🏷️ Auto-assigned tags: ${assignedTags.join(', ')}');
    }
    
    return recipeId;
  }

  /// Example: Search recipes by multiple tags
  static Future<void> searchByTags() async {
    final quickEasyRecipes = await RecipeTaggingService.getRecipeIdsByTags(['Quick', 'Easy']);
    print('🔍 Found ${quickEasyRecipes.length} quick and easy recipes');
  }
} 