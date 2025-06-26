import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/models/post.dart';

class MockDataService {
  static final List<Recipe> _recipes = [
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
        'peeled and left whole',
        '50g unsalted butter',
        'sea salt and freshly ground black pepper',
      ],
      directions: [
        'Put a large saucepan of water on to boil.',
        'Finely chop the 100g pancetta, having first removed any rind. Finely grate 50g pecorino cheese and 50g parmesan and mix them together.',
        'Beat the 3 large eggs in a medium bowl and season with a little freshly grated black pepper. Set everything aside.',
        'Add 1 tsp salt to the boiling water, add 350g spaghetti and when the water comes back to the boil, cook at a constant simmer, covered, for 10 minutes or until al dente (just cooked).',
        'Squash 2 peeled plump garlic cloves with the blade of a knife, just to bruise it.',
        'While the spaghetti is cooking, fry the pancetta with the garlic. Drop 50g unsalted butter into a large frying pan or wok and, as soon as the butter has melted, tip in the pancetta and garlic.',
        'Leave to cook on a medium heat for about 5 minutes, stirring often, until the pancetta is golden and crisp. The garlic has now imparted its flavour, so take it out with a slotted spoon and discard.',
        'Keep the heat under the pancetta on low. When the pasta is ready, lift it from the water with a pasta fork or tongs and put it in the frying pan with the pancetta. Don’t worry if a little water drops in the pan as well (you want this to happen) and don’t throw the pasta water away yet.',
        'Mix most of the cheese in with the eggs, keeping a small handful back for sprinkling over later.',
        'Take the pan of spaghetti and pancetta off the heat. Now quickly pour in the eggs and cheese. Using the tongs or a long fork, lift up the spaghetti so it mixes easily with the egg mixture, which thickens but doesn’t scramble, and everything is coated.',
        'Add extra pasta cooking water to keep it saucy (several tablespoons should do it). You don’t want it wet, just moist. Season with a little salt, if needed.',
        'Use a long-pronged fork to twist the pasta on to the serving plate or bowl. Serve immediately with a little sprinkling of the remaining cheese and a grating of black pepper. If the dish does get a little dry before serving, splash in some more hot pasta water and the glossy sauciness will be revived.',
      ],
      nutritions: [
        'Kcal 656KCal',
        'Fat 30.03g',
        'Saturates 15g',
        'Carbs 66g',
        'Sugars 4g',
        'Fibre 4g',
        'Protein 29g',
        'Salt 1.65g',
      ],
      authorId: 'user1',
      authorName: 'Chef Teresa',
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
        '2 teaspoons extra-virgin olive oil',
        '¼ teaspoon kosher salt',
        '¼ teaspoon freshly ground black pepper',
      ],
      directions: [
        'Gather all ingredients. Preheat the oven to 400 degrees F (200 degrees C)',
        'Brush bread slices on both sides lightly with 1 tablespoon oil and place on large baking sheet. Toast bread until golden, about 5 to 10 minutes, turning halfway through.',
        'Meanwhile, toss together tomatoes, basil, Parmesan cheese, and garlic in a bowl.',
        'Mix  in balsamic vinegar, 2 teaspoons olive oil, kosher salt, and pepper.',
        'Spoon tomato mixture onto toasted bread slices.',
        'Serve immediately and enjoy!',
      ],
      nutritions: [
        'Total Fat 4g',
        'Saturated Fat 1g',
        'Cholesterol 3mg',
        'Sodium 484mg',
        'Total Carbohydrate 33g',
        'Dietary Fiber 1g',
        'Protein 8g',
        'Vitamin C 1mg',
        'Calcium 70mg',
        'Iron 2mg',
        'Potassium 88mg',
      ],
      authorId: 'user2',
      authorName: 'Chef Mike',
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
        '1 1/8 tsp onion powder',
        '1 cup water , icy cold or quality sparkling water',
        '12 green onion  tops (green part), cleaned and cut lengthways to fit your skillet',
        '100 g calamari (3.5 ounces), cleaned and cut into little finger sized pieces',
        '100 g prawns (3.5 ounces), cleaned and cut into smaller pieces',
        'A few sprinkles ground black peppers , to marinate seafood',
        '1 egg , beaten',
        '1 red chili (optional), thinly diagonally sliced',
        '6 Tbsp cooking oil (approx. 3 Tbsp per pancake), I used rice bran oil',
      ],
      directions: [
        'Gather all ingredients. Preheat the oven to 400 degrees F (200 degrees C)',
        'Brush bread slices on both sides lightly with 1 tablespoon oil and place on large baking sheet. Toast bread until golden, about 5 to 10 minutes, turning halfway through.',
        'Meanwhile, toss together tomatoes, basil, Parmesan cheese, and garlic in a bowl.',
        'Mix  in balsamic vinegar, 2 teaspoons olive oil, kosher salt, and pepper.',
        'Spoon tomato mixture onto toasted bread slices.',
        'Serve immediately and enjoy!',
      ],
      nutritions: [
        'Calories: 783kcal',
        'Carbohydrates: 62g',
        'Protein: 29g',
        'Fat: 46g',
        'Saturated Fat: 4g',
        'Polyunsaturated Fat: 13g',
        'Monounsaturated Fat: 28g',
        'Trans Fat: 1g',
        'Cholesterol: 324mg',
        'Sodium: 1773mg',
        'Potassium: 563mg',
        'Fiber: 4g | Sugar: 3g',
        'Vitamin A: 1067IU',
        'Vitamin C: 51mg',
        'Calcium: 175mg',
        'Iron: 6mg',
      ],
      authorId: 'user3',
      authorName: 'Chef Sophia',
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
        '1 lb potatoes (I\'m using russet, but white and red potatoes have less starch and work great as well)',
        '3.5-5 tbsp Mizkan Natural Rice Vinegar (2 Tbsp. for soaking + 1.5-2 Tbsp. for seasoning potatoes)',
        '1/2 tsp salt',
        '1/2 tsp sugar',
        '1/2 tsp mushroom or chicken bouillon powder (optional)',
        '1/4 bell pepper',
        '3 cloves garlic',
        '3-4 dried red chilis',
        '1/2 tbsp red Sichuan peppercorns (optional)',
        'scallions',
        '3 tbsp neutral oil (avocado, vegetable, canola, etc.)',
      ],
      directions: [
        'Peel the potatoes. Slice as evenly as possible into 1/8-inch layers (or use a mandolin), then slice into 1/8 inch matchsticks.',
        'To remove excess starch, wash the potatoes in a bowl of water until the water runs clear. Once water runs clear, submerge potatoes in a large bowl of water with 2 Tbsp. of rice vinegar. ',
        'While that sits, prepare the aromatics: thinly slice garlic. Then thinly slice bell peppers and scallions into 1/8 matchsticks like the potatoes. Remove seeds from dried chilis if desired. ',
        'Drain the potatoes and let them sit in a sieve or colander to get rid of any excess water.',
        'Heat up a pan to medium heat and add 2-3 Tbsp. of neutral oil, followed by the red Sichuan peppercorns, if using. ',
        'Once oil is hot, add the sliced garlic and dried chilis and stir fry for 1-2 min or until fragrant. ',
        'Add the potatoes and stir fry for 2-3 min or until slightly translucent. ',
        'Add the bell peppers, scallions, and seasonings: salt, sugar, mushroom or chicken bouillon, and 1.5-2 Tbsp. rice vinegar (adjust to your taste preference). ',
        'Keep stir frying for another 3-5 min or until potatoes are just slightly crunchy (longer if you prefer softer potatoes). Enjoy! ',
      ],
      nutritions: [
        'Calories: 133kcal',
        'Carbohydrates: 15g',
        'Protein: 3g',
        'Fat: 7g',
        'Saturated Fat: 5g',
        'Sodium: 844mg',
        'Potassium: 458mg',
        'Fiber: 2g',
        'Vitamin A: 265IU',
        'Vitamin C: 13mg',
        'Calcium: 37mg',
        'Iron: 3.6mg'
      ],
      authorId: 'user2',
      authorName: 'Chef Mike',
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
        '1 lb shrimps (shell on) (450g)',
        '1 lb bone-in country style pork ribs (225g)',
        '½ lb pork belly (225g)',
        '5 tbsp vegetable oil',
        '8 shallots or 1 large onion, peeled and finely sliced',
        '8 shallots or 1 large onion, peeled and blended',
        '4 tbsp chili paste',
        'Salt to taste',
        '2 tbsp fish sauce',
        '12 oz bean sprouts (trimmed) (340g)',
        '4 oz kangkung / ong choy / water spinach (115g)',
        '1 lb fresh yellow noodles (450g)',
      ],
      directions: [
        'Peel shrimps, reserving the shell. Do not discard. Pat dry with paper towels.',
        'In a large pot, bring about one third pot of water to boil. Add pork ribs and pork belly. Continue to boil for 5 minutes. Remove pork ribs and pork belly with a pair of thongs. Discard water.',
        'Fill the same pot with 10 cups (2.4 liters) of water. Bring it to a boil. Return pork ribs and pork belly to the pot. Lower heat and allow it to simmer.',
        'Heat 4 tablespoons vegetable oil in a medium sized pan. Add sliced shallots and fry until fragrant and golden brown in color, about 5 minutes. Remove with strainer and set aside.',
        'Add blended onion and fry for about 3 minutes. Add chili paste and continue to fry for another 2 minutes. Transfer to a small bowl.',
        'Add remaining 1 tablespoon vegetable oil into the same pan. Add shrimp shells and fry until shells turn pink, about 3 minutes. Remove and allow fried shrimp shells to cool slightly. Blend the shells in a food processor until fine. Transfer to a filter bag.',
        'Place filter bag and 2 tablespoons of cooked chili paste (keep the remaining as condiment) to the soup. Season with salt and allow soup to simmer for 1½ hours.',
        'After half an hour of simmering, remove pork belly. When cool enough to handle, slice thinly and set aside.',
        'In the meantime, fill a separate pot half full of water. Bring to a boil. Scald bean sprouts for about 20 seconds. Remove with a metal strainer. Do the same for water spinach. Discard water.',
        'Refill pot with water and bring it to a boil. Add noodles and allow it to cook for about 3 minutes or according to packaging instructions. Do not overcook. Remove with metal strainer.',
        'When soup is done, remove pork ribs and filter bag with processed shrimp shells. Discard filter bag. Remove meat from pork ribs or discard. Add fish sauce and shrimps to the soup and allow it to cook for about 3 minutes until shrimps curl and turn pink. Remove and set aside.',
        'Place a portion of noodles, bean sprouts, and water spinach in a bowl. Pour soup over noodles and vegetables. Top with shrimps, sliced streaky pork, and reserved chili condiment. Serve immediately.',
      ],
      nutritions: [
        'Calories:842kcal',
      ],
      authorId: 'user2',
      authorName: 'Chef Mike',
    ),
    Recipe(
      id: '6',
      title: 'Basque Cheesecake',
      category: 'Dessert',
      image: 'assets/images/basque_cheesecake.png',
      rating: 4.8,
      prepTimeMinutes: 60,
      servings: 1,
      calories: 398,
      ingredients: [
        '2 pounds (four 8oz blocks) full fat cream cheese, room temp',
        '1 1/2 cups (300g) granulated sugar',
        '5 large eggs, room temp',
        '1 tsp vanilla extract',
        '1 3/4 cups (420g) heavy cream',
        '1 tsp salt',
        '1/4 cup (33g) all-purpose flour',
      ],
      directions: [
        'Preheat the oven to 400F and butter the inside of a 9″ springform pan.',
        'Press two layers of parchment paper into the bottom and up the sides. They should stick up about 2 inches above the edge of the pan.',
        'Cream together the cream cheese and sugar on medium low speed using a hand or stand mixer with the paddle attachment.',
        'Mix in the eggs one at a time on low speed and then the vanilla.',
        'Pour the heavy cream in a slow and steady stream while the mixer is on low speed. Once smooth, sift in your flour and salt and fold to combine.',
        'Bake for 60-65 minutes or until the top is completely burnt and it has a slight jiggle to it.',
        'Let it cool to room temperature for about an hour then remove from the pan and slice. You can also leave it in the pan and place it in the fridge for a couple hours to completely set (my personal preference). Enjoy!'
      ],
      nutritions: [
        'Calories:398cal',
        'Carbohydrates:23g',
        'Protein:7g',
        'Fat:32g',
        'Saturated Fat:19g',
        'Polyunsaturated Fat:2g',
        'Monounsaturated Fat:8g',
        'Trans Fat:0.01g',
        'Cholesterol:146mg',
        'Sodium:224mg',
        'Potassium:129mg',
        'Fiber:0.1g',
        'Sugar:20g',
        'Vitamin A:1283IU',
        'Vitamin C:0.1mg',
        'Calcium:86mg',
        'Iron:0.5mg',
      ],
      authorId: 'user2',
      authorName: 'Chef Mike',
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
        'Laksa Paste:',
        '5 small red Thai chilies (bird\'s eye) stalks removed',
        '4 shallots or 1 medium onion chopped',
        '1 tablespoon fresh ginger minced',
        '1 tablespoon fresh galangal blue ginger, chopped',
        '3 cloves garlic minced',
        '2 stalks fresh lemongrass cut into large chunks',
        '6 candlenuts (or you can use macadamia nuts or a handful of cashew nuts if you can\'t find candlenut)',
        '2 tablespoon ground coriander',
        '1 tablespoon ground cumin',
        '3 Tbsp (50g) tamarind pulp + ¾ C warm water (or if using tamarind paste, depending on how runny the tamarind paste is, use 4-6 tablespoon and omit the water)',
        '2 tablespoon avocado oil or vegetable oil',
        '1 tablespoon coconut palm sugar or brown sugar',
        '1 tablespoon curry powder Malaysian-style',
        '1 tablespoon paprika',
        '2 teaspoon sea salt',
        'Soup base:',
        '4 C chicken broth add more if you prefer it more soupy',
        '1 can coconut milk',
        'Toppings for laksa:',
        '1 pkg rice vermicelli noodles (fine) cooked and drained',
        '2 seasoned chicken breasts cooked and shredded',
        '12 large shrimp/prawns boiled and sliced in half',
        '4 large eggs scrambled and cooked omelette-style, cut into thin strips',
        '1 pkg tofu puffs boiled and drained',
        '1 cucumber julienned',
        '1 pkg bean sprouts washed and lightly cooked with hot boiled water',
        '2 limes cut into wedges',
        'laksa leaves (rau ram, Vietnamese coriander) cut into thin strips',
        'red Thai chilies optional',
        'belacan (fermented shrimp paste) optional'
      ],
      directions: [
        'In a food processor or high-powered blender, combine the red Thai chilies, shallots, ginger, galangal, garlic, lemongrass, candlenuts (or macadamia/cashew), coriander, cumin, tamarind paste, warm water, and oil. Pulse until a smooth paste is formed.',
        'Transfer the pureed paste into a large pot and cook over medium heat for about 30-40 minutes, until fragrant, stirring intermittently.',
        'Once the paste is nutty in aroma and has thickened significantly, add in the sugar, curry powder, paprika, and salt, and cook for another 5 minutes. Again, stirring every so often.',
        'Turn off the heat.',
        'If not using the paste right away, let the laksa paste completely cool and store in an airtight container in the fridge for up to 1 week, or freezer for up to 6 months.',
        'To the laksa paste, add in 4 C of chicken broth and 1 can coconut milk. Stir and bring to a simmer over medium heat.',
        'If the consistency of the soup is a little too thick, add a little more chicken broth or water. Keep the soup hot for serving.',
        'Place the cooked rice vermicelli noodles into a serving bowl. Top with shredded chicken, shrimp, egg, tofu puffs, cucumber, and bean sprouts.',
        'Ladle the hot soup over top of the noodles. Add a squeeze of lime over top and garnish with laksa leaves (rau ram), additional Thai chilies and belacan (if desired).',
        'Serve immediately.'
      ],
      nutritions: [
        'Calories: 290kcal',
        'Carbohydrates: 11g',
        'Protein: 10g',
        'Fat: 25g',
        'Saturated Fat: 16g',
        'Trans Fat: 1g',
        'Cholesterol: 139mg',
        'Sodium: 1501mg',
        'Potassium: 536mg',
        'Fiber: 4g',
        'Sugar: 4g',
        'Vitamin A: 299IU',
        'Vitamin C: 25mg',
        'Calcium: 111mg',
        'Iron: 5mg'
      ],
      authorId: 'user2',
      authorName: 'Chef Mike',
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
        '8 small Granny Smith apples, or as needed',
        '½ cup unsalted butter',
        '3 tablespoons all-purpose flour',
        '½ cup white sugar',
        '½ cup packed brown sugar',
        '¼ cup water',
        '1 (9 inch) double-crust pie pastry, thawed'
      ],
      directions: [
        'Gather the ingredients. Preheat the oven to 425 degrees F (220 degrees C). Peel and core apples, then thinly slice. Set aside.',
        'Melt butter in a saucepan over medium heat. Add flour and stir to form a paste; cook until fragrant, about 1 to 2 minutes. Add both sugars and water; bring to a boil. Reduce the heat to low and simmer for 3 to 5 minutes. Remove from the heat.',
        'Place sliced apples into the bottom crust, forming a slight mound. Lay four pastry strips vertically and evenly spaced over apples, using longer strips in the center and shorter strips at the edges.',
        'Place sliced apples into the bottom crust, forming a slight mound. Lay four pastry strips vertically and evenly spaced over apples, using longer strips in the center and shorter strips at the edges.',
        'Make a lattice crust: Fold the first and third strips all the way back so they\'re almost falling off the pie. Lay one of the unused strips perpendicularly over the second and fourth strips, then unfold the first and third strips back into their original position.',
        'Fold the second and fourth vertical strips back. Lay one of the three unused strips perpendicularly over top. Unfold the second and fourth strips back into their original position. Repeat Steps 6 and 7 to weave in the last two strips of pastry. Fold and trim excess dough at the edges as necessary, and pinch to secure',
        'Slowly and gently pour sugar-butter mixture over lattice crust, making sure it seeps over sliced apples. Brush some onto lattice, but make sure it doesn\'t run off the sides.',
        'Bake in the preheated oven for 15 minutes. Reduce the temperature to 350 degrees F (175 degrees C) and continue baking until apples are soft, 35 to 45 minutes.',
        'Serve and enjoy!'
      ],
      nutritions: [
        'Total Fat: 19g',
        'Saturated Fat: 9g',
        'Cholesterol: 31mg',
        'Sodium: 124mg',
        'Total Carbohydrate: 52g',
        'Dietary Fiber: 3g',
        'Protein: 2g',
        'Vitamin C: 5mg',
        'Calcium: 23mg',
        'Iron: 1mg',
        'Potassium: 156mg',
      ],
      authorId: 'user2',
      authorName: 'Chef Mike',
    ),
  ];

  static User _currentUser = User(
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
  );

  static final List<Post> _posts = [
    Post(
      id: 'post1',
      userId: 'user1',
      userName: 'Chef Teresa',
      userProfileUrl: 'assets/images/profile1.jpg',
      content:
          'Just made this amazing pies with apple and honey! So delicious and easy to make.',
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
      comments: [
        PostComment(
          id: 'comment1',
          userId: 'user3',
          userName: 'Chef Sophia',
          content:
              'Thai green curry is my favorite! Would love to see your take on it.',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
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

  // Get all recipes
  static List<Recipe> getAllRecipes() {
    return List.from(_recipes);
  }

  // Get daily inspiration recipes
  static List<Recipe> getDailyInspirationRecipes() {
    // In a real app, this would be curated daily or fetched from a backend
    // For now, return a subset of recipes to display in the daily inspiration section
    return [
      _recipes[3],
      _recipes[0]
    ]; // Teriyaki Chicken and Crepes with Orange and Honey
  }

  // Get recipes by category
  static List<Recipe> getRecipesByCategory(String category) {
    return _recipes.where((recipe) => recipe.category == category).toList();
  }

  // Get recipe by ID
  static Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get current user
  static User getCurrentUser() {
    return _currentUser;
  }

  // Get favorite recipes
  static List<Recipe> getFavoriteRecipes() {
    return _recipes
        .where((recipe) => _currentUser.favoriteRecipes.contains(recipe.id))
        .toList();
  }

  // Get all posts
  static List<Post> getAllPosts() {
    return List.from(_posts);
  }

  // Mock adding a new post
  static Post addPost(String content, String? image) {
    final newPost = Post(
      id: 'post${_posts.length + 1}',
      userId: _currentUser.id,
      userName: _currentUser.name,
      userProfileUrl: _currentUser.profileImage,
      content: content,
      image: image,
      createdAt: DateTime.now(),
    );

    // In a real app, this would be saved to a database
    // _posts.add(newPost);

    return newPost;
  }

  // Update user profile
  static Future<bool> updateUserProfile(User updatedUser) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      _currentUser = updatedUser;
      // In a real app, this would save to a database or API
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update profile image
  static Future<bool> updateProfileImage(String imagePath) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      _currentUser = _currentUser.copyWith(profileImageUrl: imagePath);
      // In a real app, this would upload the image and save the URL
      return true;
    } catch (e) {
      return false;
    }
  }
}
