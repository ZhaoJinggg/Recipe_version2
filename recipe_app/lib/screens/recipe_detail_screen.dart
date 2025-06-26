import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/comment.dart';
import 'package:recipe_app/services/mock_data_service.dart';
import 'package:recipe_app/widgets/recipe_nutrition_widget.dart';
import 'package:recipe_app/widgets/recipe_ingredients_widget.dart';
import 'package:recipe_app/widgets/recipe_directions_widget.dart';
import 'package:recipe_app/widgets/recipe_comments_widget.dart';

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
  late Recipe? _recipe;
  //final bool _isFavorite = false;
  int _currentImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();

  // Mock images for the swipeable gallery
  final List<String> _additionalImages = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
    'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327',
  ];

  final List<Comment> _comments = [
    Comment(
      username: 'Sarah',
      text:
          'I made this last night and it was delicious! Will definitely make again.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 12,
    ),
    Comment(
      username: 'Mike',
      text:
          'Great recipe! I added some extra garlic and it turned out amazing.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      likes: 8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  void _loadRecipe() {
    _recipe = MockDataService.getRecipeById(widget.recipeId);
    setState(() {});
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleCommentSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(
          0,
          Comment(
            username: 'You',
            text: text.trim(),
            timestamp: DateTime.now(),
          ),
        );
      });
      _commentController.clear();
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
          _buildCommentInput(),
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
              Tab(text: 'Comments'),
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
                RecipeCommentsWidget(
                  comments: _comments,
                  onCommentSubmitted: _handleCommentSubmitted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppColors.primary,
            onPressed: () => _handleCommentSubmitted(_commentController.text),
          ),
        ],
      ),
    );
  }
}
