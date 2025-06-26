import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/models/post.dart';
import 'package:recipe_app/models/grocery_item.dart';
import 'package:recipe_app/models/ingredient.dart';
import 'package:recipe_app/models/tag.dart';

class DataMigrationService {
  // Migrate all mock data to Firebase
  static Future<bool> migrateAllData() async {
    try {
      print('Starting data migration...');

      // Migrate users
      await _migrateUsers();
      print('Users migrated successfully');

      // Migrate recipes
      await _migrateRecipes();
      print('Recipes migrated successfully');

      // Migrate posts
      await _migratePosts();
      print('Posts migrated successfully');

      // Migrate ingredients and tags
      await _migrateIngredientsAndTags();
      print('Ingredients and tags migrated successfully');

      // Add sample grocery items
      await _addSampleGroceryItems();
      print('Sample grocery items added successfully');

      print('Data migration completed successfully!');
      return true;
    } catch (e) {
      print('Error during data migration: $e');
      return false;
    }
  }

  // Migrate users
  static Future<void> _migrateUsers() async {
    final users = [
      User(
        id: 'current_user',
        name: 'Teresa',
        email: 'teresa@example.com',
        profileImageUrl: 'assets/images/profile1.jpg',
        bio:
            'Passionate home cook who loves experimenting with flavors from around the world. Always on the lookout for new recipes to try and share with the community. Specializing in healthy, quick meals that don\'t compromise on taste.',
        phone: '+1 234 567 8900',
        dateOfBirth: '15 March 1995',
        gender: 'Female',
        favoriteRecipes: ['1'],
      ),
      User(
        id: 'user1',
        name: 'Chef Teresa',
        email: 'chef.teresa@example.com',
        profileImageUrl: 'assets/images/profile1.jpg',
        bio: 'Professional chef specializing in Italian cuisine',
        gender: 'Female',
      ),
      User(
        id: 'user2',
        name: 'Chef Mike',
        email: 'chef.mike@example.com',
        profileImageUrl: 'assets/images/profile4.jpg',
        bio: 'Culinary expert with passion for Asian fusion',
        gender: 'Male',
      ),
      User(
        id: 'user3',
        name: 'Chef Sophia',
        email: 'chef.sophia@example.com',
        profileImageUrl: 'assets/images/profile2.jpg',
        bio: 'Dessert specialist and pastry chef',
        gender: 'Female',
      ),
    ];

    for (final user in users) {
      await FirebaseService.createOrUpdateUser(user);
    }
  }

  // Migrate recipes with updated model structure
  static Future<void> _migrateRecipes() async {
    final recipes = [
      Recipe(
        id: '1',
        title: 'Spaghetti Carbonara',
        category: 'Main Course',
        image: 'assets/images/spaghetti_carbonara.png',
        rating: 4.5,
        prepTimeMinutes: 30,
        servings: 4,
        calories: 656,
        ingredients: [
          '100g pancetta',
          '50g pecorino cheese',
          '50g parmesan',
          '3 large eggs',
          '350g spaghetti',
          '2 plump garlic cloves',
          '50g unsalted butter',
          'sea salt and freshly ground black pepper',
        ],
        directions: [
          'Put a large saucepan of water on to boil.',
          'Finely chop the 100g pancetta, having first removed any rind.',
          'Beat the 3 large eggs in a medium bowl and season with black pepper.',
          'Add 1 tsp salt to the boiling water, add 350g spaghetti and cook for 10 minutes.',
          'While the spaghetti is cooking, fry the pancetta with the garlic.',
          'Mix the eggs and cheese together.',
          'Take the pan off the heat and quickly pour in the eggs and cheese.',
          'Season with salt if needed and serve immediately.',
        ],
        nutritions: [
          'Kcal 656KCal',
          'Fat 30.03g',
          'Protein 29g',
          'Carbs 66g',
        ],
        authorId: 'user1',
        authorName: 'Chef Teresa',
        description:
            'Classic Italian pasta dish with eggs, cheese, and pancetta',
        difficultyLevel: 'Medium',
        fat: 30.03,
        protein: 29.0,
        carbs: 66.0,
        tags: ['Italian', 'Pasta', 'Quick'],
      ),
      Recipe(
        id: '2',
        title: 'Balsamic Bruschetta',
        category: 'Appetizers',
        image: 'assets/images/balsamic_bruschetta.png',
        rating: 4.8,
        prepTimeMinutes: 20,
        servings: 8,
        calories: 197,
        ingredients: [
          '1 loaf French bread, cut into ¼-inch slices',
          '1 tablespoon extra-virgin olive oil',
          '8 roma (plum) tomatoes, diced',
          '⅓ cup chopped fresh basil',
          '1 ounce Parmesan cheese, freshly grated',
          '2 cloves garlic, minced',
          '1 tablespoon good quality balsamic vinegar',
          '¼ teaspoon kosher salt',
          '¼ teaspoon freshly ground black pepper',
        ],
        directions: [
          'Preheat the oven to 400 degrees F (200 degrees C)',
          'Brush bread slices with oil and toast until golden',
          'Mix tomatoes, basil, Parmesan cheese, and garlic in a bowl',
          'Add balsamic vinegar, olive oil, salt, and pepper',
          'Spoon tomato mixture onto toasted bread slices',
          'Serve immediately and enjoy!',
        ],
        nutritions: [
          'Total Fat 4g',
          'Protein 8g',
          'Carbohydrates 33g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Fresh and flavorful Italian appetizer',
        difficultyLevel: 'Easy',
        fat: 4.0,
        protein: 8.0,
        carbs: 33.0,
        tags: ['Italian', 'Appetizer', 'Vegetarian'],
      ),
      Recipe(
        id: '3',
        title: 'Korean Seafood Pancakes',
        category: 'Appetizers',
        image: 'assets/images/korean_pancake.png',
        rating: 4.9,
        prepTimeMinutes: 30,
        servings: 2,
        calories: 783,
        ingredients: [
          '1 cup plain flour',
          '1 Tbsp cornstarch',
          '1 1/8 tsp fine salt',
          '1 1/8 tsp garlic powder',
          '1 cup icy cold water',
          '12 green onion tops',
          '100g calamari, cleaned and cut',
          '100g prawns, cleaned',
          '1 egg, beaten',
          '6 Tbsp cooking oil',
        ],
        directions: [
          'Mix flour, cornstarch, salt, and garlic powder',
          'Add cold water to make batter',
          'Prepare seafood and green onions',
          'Heat oil in pan',
          'Pour batter and add toppings',
          'Cook until golden and crispy',
          'Serve hot with dipping sauce',
        ],
        nutritions: [
          'Calories: 783kcal',
          'Carbohydrates: 62g',
          'Protein: 29g',
          'Fat: 46g',
        ],
        authorId: 'user3',
        authorName: 'Chef Sophia',
        description: 'Crispy Korean pancake loaded with seafood',
        difficultyLevel: 'Medium',
        fat: 46.0,
        protein: 29.0,
        carbs: 62.0,
        tags: ['Korean', 'Seafood', 'Appetizer'],
      ),
      Recipe(
        id: '4',
        title: 'Sichuan Hot&Sour Shredded Potatoes',
        category: 'Appetizers',
        image: 'assets/images/shredded_potatoes.png',
        rating: 4.7,
        prepTimeMinutes: 30,
        servings: 4,
        calories: 153,
        ingredients: [
          '1 lb potatoes (russet)',
          '3.5-5 tbsp rice vinegar',
          '1/2 tsp salt',
          '1/2 tsp sugar',
          '1/4 bell pepper',
          '3 cloves garlic',
          '3-4 dried red chilis',
          '1/2 tbsp red Sichuan peppercorns',
          'scallions',
          '3 tbsp neutral oil',
        ],
        directions: [
          'Peel and julienne potatoes',
          'Wash potatoes until water runs clear',
          'Prepare aromatics',
          'Heat oil and add spices',
          'Stir fry potatoes until translucent',
          'Add seasonings and vegetables',
          'Cook until slightly crunchy',
        ],
        nutritions: [
          'Calories: 133kcal',
          'Carbohydrates: 15g',
          'Protein: 3g',
          'Fat: 7g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Spicy and tangy Sichuan-style potato dish',
        difficultyLevel: 'Medium',
        fat: 7.0,
        protein: 3.0,
        carbs: 15.0,
        tags: ['Chinese', 'Spicy', 'Vegetarian'],
      ),
      Recipe(
        id: '5',
        title: 'Penang Hokkien Mee (Prawn Mee)',
        category: 'Main Course',
        image: 'assets/images/penang_hokkien_mee.png',
        rating: 4.3,
        prepTimeMinutes: 120,
        servings: 4,
        calories: 842,
        ingredients: [
          '1 lb shrimps (shell on)',
          '1 lb bone-in pork ribs',
          '½ lb pork belly',
          '5 tbsp vegetable oil',
          '8 shallots, sliced',
          '4 tbsp chili paste',
          '2 tbsp fish sauce',
          '12 oz bean sprouts',
          '4 oz kangkung',
          '1 lb fresh yellow noodles',
        ],
        directions: [
          'Prepare prawn stock',
          'Cook pork ribs and belly',
          'Make chili oil',
          'Prepare noodles and vegetables',
          'Assemble bowls',
          'Serve with garnishes',
        ],
        nutritions: [
          'Calories: 842kcal',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Authentic Penang-style prawn noodle soup',
        difficultyLevel: 'Hard',
        fat: 35.0,
        protein: 45.0,
        carbs: 80.0,
        tags: ['Malaysian', 'Noodles', 'Seafood'],
      ),
      Recipe(
        id: '6',
        title: 'Basque Cheesecake',
        category: 'Dessert',
        image: 'assets/images/basque_cheesecake.png',
        rating: 4.8,
        prepTimeMinutes: 60,
        servings: 8,
        calories: 398,
        ingredients: [
          '2 pounds full fat cream cheese',
          '1 1/2 cups granulated sugar',
          '5 large eggs',
          '1 tsp vanilla extract',
          '1 3/4 cups heavy cream',
          '1 tsp salt',
          '1/4 cup all-purpose flour',
        ],
        directions: [
          'Preheat oven to 400F',
          'Line springform pan with parchment',
          'Cream cheese and sugar',
          'Add eggs and vanilla',
          'Stream in heavy cream',
          'Fold in flour and salt',
          'Bake until burnt top',
          'Cool and serve',
        ],
        nutritions: [
          'Calories: 398cal',
          'Carbohydrates: 23g',
          'Protein: 7g',
          'Fat: 32g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Rich and creamy burnt Basque cheesecake',
        difficultyLevel: 'Medium',
        fat: 32.0,
        protein: 7.0,
        carbs: 23.0,
        tags: ['Dessert', 'Cheesecake', 'Spanish'],
      ),
      Recipe(
        id: '7',
        title: 'Sarawak Laksa',
        category: 'Main Course',
        image: 'assets/images/sarawak_laksa.png',
        rating: 4.4,
        prepTimeMinutes: 90,
        servings: 6,
        calories: 290,
        ingredients: [
          '5 small red Thai chilies',
          '4 shallots',
          '1 tablespoon fresh ginger',
          '1 tablespoon galangal',
          '3 cloves garlic',
          '2 stalks lemongrass',
          '6 candlenuts',
          '2 tablespoon ground coriander',
          '1 tablespoon ground cumin',
          '3 Tbsp tamarind pulp',
          '4 C chicken broth',
          '1 can coconut milk',
        ],
        directions: [
          'Make laksa paste',
          'Cook paste until fragrant',
          'Add spices and seasonings',
          'Prepare soup base',
          'Cook toppings',
          'Assemble bowls',
          'Serve with garnishes',
        ],
        nutritions: [
          'Calories: 290kcal',
          'Carbohydrates: 11g',
          'Protein: 10g',
          'Fat: 25g',
        ],
        authorId: 'user2',
        authorName: 'Chef Mike',
        description: 'Spicy and aromatic Malaysian laksa',
        difficultyLevel: 'Hard',
        fat: 25.0,
        protein: 10.0,
        carbs: 11.0,
        tags: ['Malaysian', 'Spicy', 'Noodles'],
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
        tags: ['Dessert', 'American', 'Pie'],
      ),
    ];

    for (final recipe in recipes) {
      await FirebaseService.createRecipe(recipe);
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

  // Migrate ingredients and tags
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

    // Common tags
    final tags = [
      Tag(id: 'tag1', name: 'Italian'),
      Tag(id: 'tag2', name: 'Chinese'),
      Tag(id: 'tag3', name: 'Korean'),
      Tag(id: 'tag4', name: 'Malaysian'),
      Tag(id: 'tag5', name: 'Spanish'),
      Tag(id: 'tag6', name: 'American'),
      Tag(id: 'tag7', name: 'Vegetarian'),
      Tag(id: 'tag8', name: 'Vegan'),
      Tag(id: 'tag9', name: 'Gluten-Free'),
      Tag(id: 'tag10', name: 'Quick'),
      Tag(id: 'tag11', name: 'Easy'),
      Tag(id: 'tag12', name: 'Medium'),
      Tag(id: 'tag13', name: 'Hard'),
      Tag(id: 'tag14', name: 'Appetizer'),
      Tag(id: 'tag15', name: 'Main Course'),
      Tag(id: 'tag16', name: 'Dessert'),
      Tag(id: 'tag17', name: 'Breakfast'),
      Tag(id: 'tag18', name: 'Spicy'),
      Tag(id: 'tag19', name: 'Seafood'),
      Tag(id: 'tag20', name: 'Healthy'),
    ];

    for (final tag in tags) {
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
}
