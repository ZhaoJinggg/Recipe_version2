import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/mock_data_service.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _allRecipes = [], _searchResults = [];
  bool _isSearching = false;
  final List<String> _recentSearches = ['Pasta', 'Chicken', 'Salad', 'Dessert'];
  final List<String> _popularTags = [
    'Healthy',
    'Quick & Easy',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Vegetarian',
    'Desserts',
    'Soups'
  ];

  static const _sectionTitleStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  @override
  void initState() {
    super.initState();
    _allRecipes = MockDataService.getAllRecipes().cast<Recipe>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) return _clearSearch();

    setState(() {
      _isSearching = true;
      final lowercaseQuery = query.toLowerCase();
      _searchResults = _allRecipes.where((recipe) {
        return recipe.title.toLowerCase().contains(lowercaseQuery) ||
            recipe.category.toLowerCase().contains(lowercaseQuery) ||
            recipe.ingredients.any((ingredient) =>
                ingredient.toLowerCase().contains(lowercaseQuery));
      }).toList();

      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }
    });
  }

  void _clearSearch() => setState(() {
        _searchController.clear();
        _searchResults = [];
        _isSearching = false;
      });

  Widget _buildSearchField() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
            hintText: 'Search recipes, ingredients...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.primary),
                    onPressed: _clearSearch)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12)),
        onChanged: _performSearch,
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildTagChip(String label, {IconData? icon}) => ActionChip(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        label: Text(label),
        onPressed: () {
          _searchController.text = label;
          _performSearch(label);
        },
        avatar: icon != null
            ? Icon(icon, size: 16, color: AppColors.primary)
            : null,
      );

  Widget _buildSectionTitle(String title) =>
      Text(title, style: _sectionTitleStyle);

  Widget _buildNoResults() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 80, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No results found', style: _sectionTitleStyle),
            const SizedBox(height: 8),
            Text('Try different keywords or filters',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary.withOpacity(0.7))),
          ],
        ),
      );

  Widget _buildCategoryCard(String title, IconData icon) => GestureDetector(
        onTap: () {
          _searchController.text = title;
          _performSearch(title);
        },
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      );

  Widget _buildSearchResults() => _searchResults.isEmpty
      ? _buildNoResults()
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) => RecipeCard(
            recipe: _searchResults[index],
            onTap: () => Navigator.pushNamed(context, '/recipe',
                arguments: {'recipeId': _searchResults[index].id}),
          ),
        );

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Recent Searches'),
            TextButton(
              onPressed: () => setState(() => _recentSearches.clear()),
              child: const Text('Clear All',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches
                .map((s) => _buildTagChip(s, icon: Icons.history))
                .toList()),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPopularTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Popular Tags'),
        const SizedBox(height: 12),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTags.map((t) => _buildTagChip(t)).toList()),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Explore by Category'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildCategoryCard('Breakfast', Icons.free_breakfast),
            _buildCategoryCard('Lunch', Icons.lunch_dining),
            _buildCategoryCard('Dinner', Icons.dinner_dining),
            _buildCategoryCard('Desserts', Icons.cake),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) _buildRecentSearches(),
          _buildPopularTags(),
          _buildCategories(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: _buildSearchField(),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pushReplacementNamed(context, '/')),
      ),
      body: _isSearching ? _buildSearchResults() : _buildSearchSuggestions(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          final routes = ['/', '', '/favorites', '/community'];
          Navigator.pushReplacementNamed(context, routes[index]);
        },
      ),
    );
  }
}
