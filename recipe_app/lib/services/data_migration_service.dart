import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/services/mock_data_service.dart';
import 'package:recipe_app/services/recipe_tagging_service.dart';
import 'package:recipe_app/models/user.dart' as AppUser;
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/post.dart';
import 'package:recipe_app/models/ingredient.dart';
import 'package:recipe_app/models/tag.dart';
import 'package:recipe_app/models/grocery_item.dart';

class DataMigrationService {
  static bool _hasRunMigration = false;

  /// Run complete data migration from mock service to Firebase
  static Future<bool> runMigration() async {
    if (_hasRunMigration) {
      print('⚠️ Data migration has already been run');
      return true;
    }

    print('🚀 Starting data migration to Firebase...');

    try {
      // Initialize Firebase first
      final firebaseInitialized = await FirebaseService.initialize();
      if (!firebaseInitialized) {
        print('❌ Failed to initialize Firebase');
        return false;
      }

      // Migrate ingredients and tags first (dependencies)
      await _migrateIngredientsAndTags();
      print('✅ Ingredients and tags migrated successfully');

      // Migrate users
      await _migrateUsers();
      print('✅ Users migrated successfully');

      // Migrate recipes with dynamic tagging
      await _migrateRecipesWithDynamicTagging();
      print('✅ Recipes migrated with dynamic tagging successfully');

      // Migrate posts
      await _migratePosts();
      print('✅ Posts migrated successfully');

      // Add sample grocery items
      await _addSampleGroceryItems();
      print('✅ Sample grocery items added successfully');

      _hasRunMigration = true;
      print('🎉 Data migration completed successfully!');
      print('📊 Check Firebase Console to verify data');
      print('🔗 https://console.firebase.google.com/project/recipe-app-6f86b/firestore');

      return true;
    } catch (e) {
      print('❌ Data migration failed: $e');
      return false;
    }
  }

  // Migrate users
  static Future<void> _migrateUsers() async {
    final users = [
      AppUser.User(
        id: 'user1',
        name: 'Chef Teresa',
        email: 'teresa@chef.com',
        phone: '+60123456789',
        gender: 'Female',
        dateOfBirth: '1990-05-15',
        bio: 'Passionate chef specializing in Italian and Mediterranean cuisine',
        profileImageUrl: 'assets/images/profile1.jpg',
      ),
      AppUser.User(
        id: 'user2',
        name: 'Chef Mike',
        email: 'mike@chef.com',
        phone: '+60123456790',
        gender: 'Male',
        dateOfBirth: '1985-08-22',
        bio: 'Expert in Asian fusion and traditional Chinese cooking',
        profileImageUrl: 'assets/images/profile4.jpg',
      ),
      AppUser.User(
        id: 'user3',
        name: 'Chef Sophia',
        email: 'sophia@chef.com',
        phone: '+60123456791',
        gender: 'Female',
        dateOfBirth: '1992-12-10',
        bio: 'Dessert specialist and baking enthusiast',
        profileImageUrl: 'assets/images/profile2.jpg',
      ),
    ];

    for (final user in users) {
      await FirebaseService.createOrUpdateUser(user);
    }
  }

  // Migrate recipes using the new dynamic tagging system
  static Future<void> _migrateRecipesWithDynamicTagging() async {
    // Create base recipes without hardcoded tags - the dynamic system will assign them
    final recipes = [
      Recipe(
        id: '1',
        title: 'Spaghetti Carbonara',
        category: 'Main Course',
        image: 'assets/images/spaghetti_carbonara.png',
        rating: 4.5,
        prepTimeMinutes: 30,
        servings: 4,
        calories: 400,
        ingredients: [
          '350g spaghetti',
          '100g pancetta',
          '4 large eggs',
          '50g pecorino cheese',
          '50g parmesan cheese',
          '2 cloves garlic',
          'Black pepper',
          'Salt',
        ],
        directions: [
          'Cook spaghetti according to package directions',
          'Fry pancetta until crispy',
          'Whisk eggs with grated cheeses',
          'Combine hot pasta with pancetta',
          'Add egg mixture off heat',
          'Toss quickly to create creamy sauce',
          'Season with black pepper',
        ],
        nutritions: [
          'Total Fat: 18g',
          'Protein: 20g',
          'Carbohydrates: 45g',
        ],
        authorId: 'user1',
        authorName: 'Chef Teresa',
        description: 'Classic Italian pasta dish with creamy egg sauce',
        difficultyLevel: 'Easy',
        fat: 18.0,
        protein: 20.0,
        carbs: 45.0,
        tags: [], // Let dynamic tagging handle this
      ),
      Recipe(
        id: '2',
        title: 'Balsamic Bruschetta',
        category: 'Appetizer',
        image: 'assets/images/balsamic_bruschetta.png',
        rating: 4.8,
        prepTimeMinutes: 20,
        servings: 6,
        calories: 150,
        ingredients: [
          '6 slices of baguette',
          '3 large tomatoes',
          '2 cloves garlic',
          '1/4 cup fresh basil',
          '2 tbsp olive oil',
          '1 tbsp balsamic vinegar',
          'Salt and pepper',
          'Mozzarella cheese (optional)',
        ],
        directions: [
          'Toast baguette slices',
          'Dice tomatoes',
          'Mince garlic and basil',
          'Mix vegetables with olive oil',
          'Add balsamic vinegar',
          'Top toasted bread',
          'Serve immediately',
        ],
        nutritions: [
          'Total Fat: 6g',
          'Protein: 4g',
          'Carbohydrates: 20g',
        ],
        authorId: 'user1',
        authorName: 'Chef Teresa',
        description: 'Fresh Italian appetizer with tomatoes and basil',
        difficultyLevel: 'Easy',
        fat: 6.0,
        protein: 4.0,
        carbs: 20.0,
        tags: [], // Let dynamic tagging handle this
      ),
      Recipe(
        id: '3',
        title: 'Korean Seafood Pancake',
        category: 'Appetizer',
        image: 'assets/images/korean_pancake.png',
        rating: 4.6,
        prepTimeMinutes: 25,
        servings: 4,
        calories: 280,
        ingredients: [
          '1 cup all-purpose flour',
          '1 cup water',
          '1 egg',
          '1 tsp salt',
          '200g mixed seafood (shrimp, squid)',
          '2 green onions',
          '1 red pepper',
          '2 tbsp vegetable oil',
          'Soy sauce for dipping',
        ],
        directions: [
          'Mix flour, water, egg, and salt for batter',
          'Chop seafood and vegetables',
          'Heat oil in pan',
          'Pour batter and add toppings',
          'Cook until golden on both sides',
          'Cut into pieces',
          'Serve with soy sauce',
        ],
        nutritions: [
          'Total Fat: 12g',
          'Protein: 18g',
          'Carbohydrates: 28g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Crispy Korean pancake with fresh seafood',
        difficultyLevel: 'Medium',
        fat: 12.0,
        protein: 18.0,
        carbs: 28.0,
        tags: [], // Let dynamic tagging handle this
      ),
      Recipe(
        id: '4',
        title: 'Thai Green Curry',
        category: 'Main Course',
        image: 'assets/images/greencurry.jpg',
        rating: 4.7,
        prepTimeMinutes: 45,
        servings: 4,
        calories: 350,
        ingredients: [
          '400ml coconut milk',
          '2 tbsp green curry paste',
          '500g chicken breast',
          '1 eggplant',
          '100g green beans',
          '2 kaffir lime leaves',
          '1 tbsp fish sauce',
          '1 tsp sugar',
          'Thai basil leaves',
          'Red chili for garnish',
        ],
        directions: [
          'Heat coconut milk in wok',
          'Add curry paste and fry',
          'Add chicken and cook through',
          'Add vegetables',
          'Season with fish sauce and sugar',
          'Add lime leaves and basil',
          'Serve with jasmine rice',
        ],
        nutritions: [
          'Total Fat: 22g',
          'Protein: 28g',
          'Carbohydrates: 15g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Authentic Thai curry with coconut milk and vegetables',
        difficultyLevel: 'Medium',
        fat: 22.0,
        protein: 28.0,
        carbs: 15.0,
        tags: [], // Let dynamic tagging handle this
      ),
      Recipe(
        id: '5',
        title: 'Penang Hokkien Mee',
        category: 'Main Course',
        image: 'assets/images/penang_hokkien_mee.png',
        rating: 4.4,
        prepTimeMinutes: 40,
        servings: 2,
        calories: 420,
        ingredients: [
          '400g fresh yellow noodles',
          '200g rice noodles',
          '200g prawns',
          '100g pork belly',
          '2 eggs',
          '100g bean sprouts',
          '3 cloves garlic',
          '2 tbsp dark soy sauce',
          '1 tbsp oyster sauce',
          'White pepper',
        ],
        directions: [
          'Prepare prawn stock',
          'Soak rice noodles',
          'Stir-fry garlic and pork',
          'Add prawns and cook',
          'Add noodles and sauces',
          'Scramble eggs in the same pan',
          'Add bean sprouts last',
          'Serve hot',
        ],
        nutritions: [
          'Total Fat: 15g',
          'Protein: 25g',
          'Carbohydrates: 45g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Traditional Malaysian stir-fried noodles',
        difficultyLevel: 'Hard',
        fat: 15.0,
        protein: 25.0,
        carbs: 45.0,
        tags: [], // Let dynamic tagging handle this
      ),
      Recipe(
        id: '6',
        title: 'Basque Cheesecake',
        category: 'Dessert',
        image: 'assets/images/basque_cheesecake.png',
        rating: 4.9,
        prepTimeMinutes: 60,
        servings: 8,
        calories: 320,
        ingredients: [
          '500g cream cheese',
          '150g sugar',
          '3 large eggs',
          '200ml heavy cream',
          '20g flour',
          '1 tsp vanilla extract',
          'Pinch of salt',
        ],
        directions: [
          'Preheat oven to 210°C',
          'Line springform pan with parchment',
          'Beat cream cheese until smooth',
          'Add sugar gradually',
          'Beat in eggs one at a time',
          'Add cream, flour, vanilla, salt',
          'Bake for 50-60 minutes until golden',
          'Cool completely before serving',
        ],
        nutritions: [
          'Total Fat: 25g',
          'Protein: 8g',
          'Carbohydrates: 20g',
        ],
        authorId: 'user3',
        authorName: 'Chef Sophia',
        description: 'Burnt Basque cheesecake with caramelized top',
        difficultyLevel: 'Medium',
        fat: 25.0,
        protein: 8.0,
        carbs: 20.0,
        tags: [], // Let dynamic tagging handle this
      ),
      Recipe(
        id: '7',
        title: 'Sarawak Laksa',
        category: 'Main Course',
        image: 'assets/images/sarawak_laksa.png',
        rating: 4.3,
        prepTimeMinutes: 90,
        servings: 4,
        calories: 380,
        ingredients: [
          '400g rice noodles',
          '300ml coconut milk',
          '2 tbsp laksa paste',
          '200g prawns',
          '200g chicken',
          '100g bean sprouts',
          '2 hard-boiled eggs',
          'Coriander leaves',
          'Lime wedges',
          'Chili oil',
        ],
        directions: [
          'Prepare laksa paste or use store-bought',
          'Cook chicken and prawns',
          'Boil rice noodles',
          'Heat coconut milk with laksa paste',
          'Add cooked proteins',
          'Assemble bowls with noodles',
          'Pour hot soup over',
          'Garnish with herbs and serve',
        ],
        nutritions: [
          'Total Fat: 25g',
          'Protein: 30g',
          'Carbohydrates: 35g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Spicy and aromatic Malaysian coconut noodle soup',
        difficultyLevel: 'Hard',
        fat: 25.0,
        protein: 10.0,
        carbs: 11.0,
        tags: [], // Let dynamic tagging handle this
      ),
      Recipe(
        id: '8',
        title: 'Apple Pie',
        category: 'Dessert',
        image: 'assets/images/apple_pie.png',
        rating: 4.4,
        prepTimeMinutes: 90,
        servings: 8,
        calories: 373,
        ingredients: [
          '8 small Granny Smith apples',
          '½ cup unsalted butter',
          '3 tablespoons all-purpose flour',
          '½ cup white sugar',
          '½ cup packed brown sugar',
          '¼ cup water',
          '1 (9 inch) double-crust pie pastry',
        ],
        directions: [
          'Prepare apples',
          'Make sugar mixture',
          'Assemble pie',
          'Create lattice top',
          'Pour sauce over',
          'Bake until golden',
          'Cool and serve',
        ],
        nutritions: [
          'Total Fat: 19g',
          'Protein: 2g',
          'Carbohydrates: 52g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Classic American apple pie with lattice crust',
        difficultyLevel: 'Medium',
        fat: 19.0,
        protein: 2.0,
        carbs: 52.0,
        tags: [], // Let dynamic tagging handle this
      ),
    ];

    for (final recipe in recipes) {
      final recipeId = await FirebaseService.createRecipe(recipe);
      if (recipeId != null) {
        print('✅ Created recipe: ${recipe.title} with dynamic tagging');
      } else {
        print('❌ Failed to create recipe: ${recipe.title}');
      }
    }
  }

  // Migrate posts
  static Future<void> _migratePosts() async {
    final posts = [
      Post(
        id: 'post1',
        userId: 'user1',
        userName: 'Chef Teresa',
        userProfileUrl: 'assets/images/profile1.jpg',
        content:
            'Just made this amazing apple pie with honey! So delicious and easy to make.',
        image: 'assets/images/apple_pie.png',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 24,
      ),
      Post(
        id: 'post2',
        userId: 'user2',
        userName: 'Chef Mike',
        userProfileUrl: 'assets/images/profile4.jpg',
        content:
            'Experimenting with some new curry recipes today. What\'s your favorite curry dish?',
        image: 'assets/images/greencurry.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 18,
      ),
      Post(
        id: 'post3',
        userId: 'user3',
        userName: 'Chef Sophia',
        userProfileUrl: 'assets/images/profile2.jpg',
        content:
            'Who else loves making desserts? Just finished this tiramisu for a family dinner tonight!',
        image: 'assets/images/tiramisu.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 42,
      ),
    ];

    for (final post in posts) {
      await FirebaseService.createPost(post);
    }
  }

  // Migrate ingredients and base tags (foundation data)
  static Future<void> _migrateIngredientsAndTags() async {
    // Common ingredients
    final ingredients = [
      Ingredient(id: 'ing1', name: 'Tomatoes'),
      Ingredient(id: 'ing2', name: 'Onions'),
      Ingredient(id: 'ing3', name: 'Garlic'),
      Ingredient(id: 'ing4', name: 'Olive Oil'),
      Ingredient(id: 'ing5', name: 'Salt'),
      Ingredient(id: 'ing6', name: 'Black Pepper'),
      Ingredient(id: 'ing7', name: 'Flour'),
      Ingredient(id: 'ing8', name: 'Eggs'),
      Ingredient(id: 'ing9', name: 'Butter'),
      Ingredient(id: 'ing10', name: 'Sugar'),
      Ingredient(id: 'ing11', name: 'Milk'),
      Ingredient(id: 'ing12', name: 'Cheese'),
      Ingredient(id: 'ing13', name: 'Chicken'),
      Ingredient(id: 'ing14', name: 'Beef'),
      Ingredient(id: 'ing15', name: 'Fish'),
      Ingredient(id: 'ing16', name: 'Rice'),
      Ingredient(id: 'ing17', name: 'Pasta'),
      Ingredient(id: 'ing18', name: 'Basil'),
      Ingredient(id: 'ing19', name: 'Oregano'),
      Ingredient(id: 'ing20', name: 'Thyme'),
    ];

    for (final ingredient in ingredients) {
      await FirebaseService.createIngredient(ingredient);
    }

    // Create base tags that will be used by the dynamic tagging system
    // Note: The dynamic system will create additional tags as needed
    final baseTags = [
      Tag(id: '', name: 'Italian'),
      Tag(id: '', name: 'Chinese'),
      Tag(id: '', name: 'Korean'),
      Tag(id: '', name: 'Malaysian'),
      Tag(id: '', name: 'Spanish'),
      Tag(id: '', name: 'American'),
      Tag(id: '', name: 'Vegetarian'),
      Tag(id: '', name: 'Vegan'),
      Tag(id: '', name: 'Gluten-Free'),
      Tag(id: '', name: 'Quick'),
      Tag(id: '', name: 'Easy'),
      Tag(id: '', name: 'Medium'),
      Tag(id: '', name: 'Hard'),
      Tag(id: '', name: 'Appetizer'),
      Tag(id: '', name: 'Main Course'),
      Tag(id: '', name: 'Dessert'),
      Tag(id: '', name: 'Breakfast'),
      Tag(id: '', name: 'Spicy'),
      Tag(id: '', name: 'Seafood'),
      Tag(id: '', name: 'Healthy'),
    ];

    for (final tag in baseTags) {
      await FirebaseService.createTag(tag);
    }
  }

  // Add sample grocery items
  static Future<void> _addSampleGroceryItems() async {
    final groceryItems = [
      GroceryItem(
        id: 'grocery1',
        userId: 'current_user',
        recipeId: '1',
        itemName: 'Pancetta',
        quantity: '100g',
      ),
      GroceryItem(
        id: 'grocery2',
        userId: 'current_user',
        recipeId: '1',
        itemName: 'Pecorino Cheese',
        quantity: '50g',
      ),
      GroceryItem(
        id: 'grocery3',
        userId: 'current_user',
        recipeId: '1',
        itemName: 'Spaghetti',
        quantity: '350g',
      ),
      GroceryItem(
        id: 'grocery4',
        userId: 'current_user',
        itemName: 'Milk',
        quantity: '1 liter',
        isChecked: true,
      ),
      GroceryItem(
        id: 'grocery5',
        userId: 'current_user',
        itemName: 'Bread',
        quantity: '1 loaf',
      ),
    ];

    for (final item in groceryItems) {
      await FirebaseService.addGroceryItem(item);
    }
  }

  /// Migrate existing recipes from hardcoded tags to dynamic tags
  /// This method can be called to update existing recipes in the database
  static Future<bool> migrateExistingRecipesToDynamicTagging() async {
    try {
      print('🔄 Starting migration of existing recipes to dynamic tagging...');
      
      // Get all existing recipes
      final existingRecipes = await FirebaseService.getAllRecipes();
      
      for (final recipe in existingRecipes) {
        print('🔄 Migrating recipe: ${recipe.title}');
        
        // Apply dynamic tagging to existing recipe
        await RecipeTaggingService.applyTagsToRecipe(
          recipeId: recipe.id,
          category: recipe.category,
          prepTimeMinutes: recipe.prepTimeMinutes,
          difficultyLevel: recipe.difficultyLevel,
          ingredients: recipe.ingredients,
          title: recipe.title,
          description: recipe.description,
          additionalTags: recipe.tags, // Preserve any existing manual tags
        );
        
        print('✅ Migrated recipe: ${recipe.title}');
      }
      
      print('🎉 Successfully migrated ${existingRecipes.length} recipes to dynamic tagging');
      return true;
    } catch (e) {
      print('❌ Error migrating existing recipes: $e');
      return false;
    }
  }

  /// Reset migration flag (for testing purposes)
  static void resetMigrationFlag() {
    _hasRunMigration = false;
  }
}
