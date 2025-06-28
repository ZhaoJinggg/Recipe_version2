import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/services/data_migration_service.dart';
import 'package:recipe_app/widgets/category_selector.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CategoryItem> _categories = [
    CategoryItem(title: 'All', icon: FontAwesomeIcons.list),
    CategoryItem(title: 'Appetizers', icon: FontAwesomeIcons.utensils),
    CategoryItem(title: 'Soups', icon: FontAwesomeIcons.bowlFood),
    CategoryItem(title: 'Salads', icon: FontAwesomeIcons.leaf),
    CategoryItem(title: 'Main Course', icon: FontAwesomeIcons.drumstickBite),
    CategoryItem(title: 'Dessert', icon: FontAwesomeIcons.iceCream),
  ];

  int _selectedCategoryIndex = 0;
  List<Recipe> _allRecipes = [];
  List<Recipe> _recipes = [];
  List<Recipe> _dailyInspirationRecipes = [];
  int _currentNavIndex = 0;
  User? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadRecipes();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final user = UserSessionService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _loadCategories() {
    // Convert FoodCategories to CategoryItem
    setState(() {
      _categories.clear();
      _categories.addAll(
        FoodCategories.categories.map(
          (category) => CategoryItem(
            title: category.title,
            icon: category.icon,
            color: category.color,
          ),
        ),
      );
    });
  }

  Future<void> _loadRecipes() async {
    try {
      setState(() {
        // You can add a loading state here if needed
      });

      final allRecipes = await FirebaseService.getAllRecipes();
      final inspirationRecipes =
          await FirebaseService.getDailyInspirationRecipes();

      setState(() {
        _allRecipes = allRecipes;
        _recipes = _allRecipes;
        _dailyInspirationRecipes = inspirationRecipes;
      });
    } catch (e) {
      print('Error loading recipes: $e');
      // Fallback to empty lists or show error message
      setState(() {
        _allRecipes = [];
        _recipes = [];
        _dailyInspirationRecipes = [];
      });
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      String selectedCategory = _categories[index].title;

      if (selectedCategory == 'All') {
        _recipes = _allRecipes;
      } else {
        _recipes = _allRecipes.where((recipe) {
          return recipe.category.toLowerCase() ==
              selectedCategory.toLowerCase();
        }).toList();
      }
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    // Navigate to different screens based on index
    switch (index) {
      case 0:
        // Already on home screen
        break;
      case 1:
        Navigator.pushNamed(context, '/search');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/community');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                color: Colors.amber,
                width: double.infinity,
                child: _isLoadingUser
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF004D40),
                          ),
                        ),
                      )
                    : _currentUser != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 40,
                                child: _currentUser!.profileImageUrl != null
                                    ? (_currentUser!.profileImageUrl!
                                            .startsWith('assets/')
                                        ? Image.asset(
                                            _currentUser!.profileImageUrl!,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          )
                                        : Image.network(
                                            _currentUser!.profileImageUrl!,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Text(
                                                _currentUser!.name[0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF004D40),
                                                ),
                                              );
                                            },
                                          ))
                                    : Text(
                                        _currentUser!.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF004D40),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                _currentUser!.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF004D40),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _currentUser!.email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF004D40),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 40,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color(0xFF004D40),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Guest User',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF004D40),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text(
                                  'Tap to Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF004D40),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
              const SizedBox(height: 20),
              _buildDrawerItem(Icons.person, 'Profile'),
              _buildDrawerItem(Icons.favorite, 'Favorites'),
              _buildDrawerItem(Icons.restaurant_menu, 'My Recipes'),
              _buildDrawerItem(Icons.settings, 'Settings'),
              _buildDrawerItem(Icons.help_outline, 'Help & Support'),
              const Divider(),
              _buildDrawerItem(Icons.tag, 'Add Tags to Recipes (Debug)',
                  isDebug: true),
              const Divider(),
              _buildDrawerItem(Icons.logout, 'Logout'),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, size: 28),
                        color: AppColors.textPrimary,
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, size: 28),
                          color: AppColors.textPrimary,
                          onPressed: () {
                            Navigator.pushNamed(context, '/search');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_basket_outlined,
                              size: 28),
                          color: AppColors.textPrimary,
                          onPressed: () {
                            Navigator.pushNamed(context, '/grocery');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none, size: 28),
                          color: AppColors.textPrimary,
                          onPressed: () {
                            // TODO: Implement notifications
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Daily Inspiration',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDailyInspiration(),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Browse by Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CategorySelector(
                categories: _categories,
                onCategorySelected: _onCategorySelected,
                initialSelected: _selectedCategoryIndex,
              ),
              const SizedBox(height: 16),
              _buildRecipeList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildDailyInspiration() {
    return SizedBox(
      height: 350, // Fixed height for the entire component
      child: PageView.builder(
        itemCount: _dailyInspirationRecipes.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final recipe = _dailyInspirationRecipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/recipe',
                arguments: {'recipeId': recipe.id},
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                // Changed from ClipRRect to Column
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 180, // Reduced from 200 to make room for text
                      width: double.infinity,
                      child: Image(
                        image: AssetImage(recipe.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Text Content Section
                  Expanded(
                    // Use Expanded to take remaining space
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 18, // Reduced from 20
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1, // Prevent text overflow
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6), // Reduced from 8
                          Row(
                            mainAxisSize: MainAxisSize
                                .min, // Prevent star row from expanding
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                Icons.star,
                                color: starIndex < recipe.rating.floor()
                                    ? AppColors.primary
                                    : Colors.grey[300],
                                size: 16, // Reduced from 18
                              );
                            }),
                          ),
                          const Spacer(), // Pushes button to bottom
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/recipe',
                                  arguments: {'recipeId': recipe.id},
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10), // Reduced padding
                              ),
                              child: const Text(
                                'SHOW DETAILS',
                                style: TextStyle(fontSize: 12), // Smaller text
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: _recipes.map((recipe) {
          return RecipeCard(
            recipe: recipe,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/recipe',
                arguments: {'recipeId': recipe.id},
              );
            },
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Properly logout using UserSessionService
              await UserSessionService.logoutUser();

              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {bool isDebug = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDebug ? Colors.orange : const Color(0xFF004D40),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: isDebug ? Colors.orange : const Color(0xFF004D40),
          fontWeight: isDebug ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        // Handle navigation based on selection
        Navigator.pop(context); // Close the drawer

        switch (title) {
          case 'Profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'Favorites':
            Navigator.pushNamed(context, '/favorites');
            break;
          case 'My Recipes':
            Navigator.pushNamed(context, '/my-recipes');
            break;
          case 'Settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'Help & Support':
            Navigator.pushNamed(context, '/help_support');
            break;
          case 'Add Tags to Recipes (Debug)':
            _runTagMigration();
            break;
          case 'Logout':
            _showLogoutDialog();
            break;
        }
      },
    );
  }

  // Temporary method to run tag migration
  void _runTagMigration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Add Tags to Recipes'),
        content: const Text(
            'This will add tags to all recipes that are missing them. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Adding tags to recipes...'),
                    ],
                  ),
                ),
              );

              try {
                // Run the tag migration
                await DataMigrationService
                    .migrateExistingRecipesToDynamicTagging();

                if (mounted) {
                  Navigator.pop(context); // Close loading dialog

                  // Show success dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Success!'),
                      content: const Text(
                          'Tags have been added to your recipes. Check the console for details.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog

                  // Show error dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: Text('Failed to add tags: $e'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text('Add Tags'),
          ),
        ],
      ),
    );
  }
}
