import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/recipe_rating.dart';
import 'package:recipe_app/models/grocery_item.dart';
import 'package:recipe_app/services/mock_data_service.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/widgets/recipe_nutrition_widget.dart';
import 'package:recipe_app/widgets/recipe_ingredients_widget.dart';
import 'package:recipe_app/widgets/recipe_directions_widget.dart';
import 'package:recipe_app/widgets/recipe_ratings_widget.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isFavorite = false;
  bool _isLoading = false;
  int _currentImageIndex = 0;
  List<RecipeRating> _ratings = [];

  // Mock images for the swipeable gallery
  final List<String> _additionalImages = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
    'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipe();
    _checkIfRecipeIsSaved();
    _loadRatings();
  }

  Future<void> _loadRecipe() async {
    _recipe = await FirebaseService.getRecipeById(widget.recipeId);
    setState(() {});
  }

  Future<void> _loadRatings() async {
    try {
      final ratings = await FirebaseService.getRatingsForRecipe(widget.recipeId);
      setState(() {
        _ratings = ratings;
      });
    } catch (e) {
      print('❌ Error loading ratings: $e');
      setState(() {
        _ratings = [];
      });
    }
  }

  Future<void> _checkIfRecipeIsSaved() async {
    try {
      final currentUser = UserSessionService.getCurrentUser();
      if (currentUser == null) {
        print('❌ No user logged in');
        setState(() {
          _isFavorite = false;
        });
        return;
      }

      final isSaved = await FirebaseService.isRecipeSavedByUser(
        currentUser.id,
        widget.recipeId,
      );
      setState(() {
        _isFavorite = isSaved;
      });
    } catch (e) {
      print('❌ Error checking if recipe is saved: $e');
      setState(() {
        _isFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = UserSessionService.getCurrentUser();
      if (currentUser == null) {
        _showSnackBar('Please log in to save recipes', Icons.error);
        return;
      }

      if (_isFavorite) {
        // Remove from favorites
        print('📝 Removing recipe from favorites...');
        await FirebaseService.unsaveRecipe(currentUser.id, widget.recipeId);
        _showSnackBar('Removed from favorites', Icons.heart_broken);
      } else {
        // Add to favorites
        print('📝 Adding recipe to favorites...');
        await FirebaseService.saveRecipe(currentUser.id, widget.recipeId);
        _showSnackBar('Added to favorites', Icons.favorite, isSuccess: true);
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
      print('✅ Recipe favorite status updated successfully');
    } catch (e) {
      print('❌ Error updating favorites: $e');
      _showSnackBar('Error updating favorites. Please try again.', Icons.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addAllIngredientsToGroceryList() async {
    if (_recipe == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = UserSessionService.getCurrentUser();
      if (currentUser == null) {
        _showSnackBar(
            'Please log in to add ingredients to grocery list', Icons.error);
        return;
      }

      int addedCount = 0;
      print(
          '📝 Adding ${_recipe!.ingredients.length} ingredients to grocery list...');

      for (String ingredient in _recipe!.ingredients) {
        final groceryItem = GroceryItem(
          id: '', // Firebase will generate this
          userId: currentUser.id,
          recipeId: widget.recipeId,
          itemName: ingredient,
          quantity: '1', // Default quantity
        );

        await FirebaseService.addGroceryItem(groceryItem);
        addedCount++;
      }

      print('✅ Successfully added $addedCount ingredients to grocery list');
      _showSnackBar(
        'Added $addedCount ingredients to grocery list',
        Icons.shopping_cart,
        isSuccess: true,
      );
    } catch (e) {
      print('❌ Error adding to grocery list: $e');
      _showSnackBar(
          'Error adding to grocery list. Please try again.', Icons.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, IconData icon, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleRatingSubmitted(double rating, String? review) async {
    final currentUser = UserSessionService.getCurrentUser();
    if (currentUser == null) {
      _showSnackBar('Please log in to rate recipes', Icons.error);
      return;
    }

    try {
      final recipeRating = RecipeRating(
        id: '',
        userId: currentUser.id,
        recipeId: widget.recipeId,
        rating: rating,
        review: review,
      );

      final success = await FirebaseService.addOrUpdateRecipeRating(recipeRating);
      
      if (success) {
        // Reload ratings to show the new rating
        await _loadRatings();
        // Reload recipe to update average rating
        await _loadRecipe();
      } else {
        throw Exception('Failed to submit rating');
      }
    } catch (e) {
      print('❌ Error submitting rating: $e');
      rethrow; // Let the widget handle the error display
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recipe == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRecipeHeader(),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                        _buildInfoRow(),
                        const SizedBox(height: 28),
                        _buildTabsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final List<String> allImages = [_recipe!.image, ..._additionalImages];

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: allImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  allImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 60),
                  ),
                );
              },
            ),
            // Image indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  allImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : AppColors.textPrimary,
                    size: 24,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRecipeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _recipe!.category,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                ...List.generate(5, (starIndex) {
                  return Icon(
                    Icons.star,
                    color: starIndex < _recipe!.rating.floor()
                        ? AppColors.primary
                        : Colors.grey[300],
                    size: 18,
                  );
                }),
                const SizedBox(width: 4),
                Text(
                  _recipe!.rating.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _recipe!.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Text(
                _recipe!.authorName[0],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'By ${_recipe!.authorName}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _addAllIngredientsToGroceryList,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to Grocery List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _isFavorite
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFavorite ? Colors.red : Colors.grey,
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.grey[600],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(
            icon: Icons.access_time,
            value: '${_recipe!.prepTimeMinutes}',
            label: 'mins',
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.people_outline,
            value: '${_recipe!.servings}',
            label: 'servings',
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.local_fire_department_outlined,
            value: '${_recipe!.calories}',
            label: 'calories',
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.layers_outlined,
            value: 'Easy',
            label: 'level',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textPrimary, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTabsSection() {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Ingredients'),
              Tab(text: 'Directions'),
              Tab(text: 'Nutrition'),
              Tab(text: 'Ratings'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 600,
            child: TabBarView(
              children: [
                RecipeIngredientsWidget(recipe: _recipe!),
                RecipeDirectionsWidget(recipe: _recipe!),
                RecipeNutritionWidget(recipe: _recipe!),
                RecipeRatingsWidget(
                  ratings: _ratings,
                  onRatingSubmitted: _handleRatingSubmitted,
                  recipeId: widget.recipeId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
