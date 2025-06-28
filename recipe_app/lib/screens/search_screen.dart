import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _searchResults = [];
  List<String> _popularTags = [];
  bool _isSearching = false;
  bool _isLoading = false;

  static const _sectionTitleStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  @override
  void initState() {
    super.initState();
    _loadPopularTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load popular tags from Firebase
  Future<void> _loadPopularTags() async {
    try {
      final tags = await FirebaseService.getPopularTags(limit: 15);
      setState(() {
        _popularTags = tags;
      });
    } catch (e) {
      print('Error loading popular tags: $e');
      // Fallback to default tags
      setState(() {
        _popularTags = [
          'Healthy', 'Quick', 'Easy', 'Vegetarian', 'Vegan', 
          'Gluten-Free', 'Spicy', 'Seafood', 'Italian', 'Chinese'
        ];
      });
    }
  }

  // Perform search using Firebase
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final results = await FirebaseService.searchRecipesAdvanced(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error performing search: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  // Search by specific tag
  Future<void> _searchByTag(String tagName) async {
    setState(() {
      _isSearching = true;
      _isLoading = true;
      _searchController.text = tagName;
    });

    try {
      final results = await FirebaseService.getRecipesByTagName(tagName);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching by tag: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  void _clearSearch() => setState(() {
        _searchController.clear();
        _searchResults = [];
        _isSearching = false;
        _isLoading = false;
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
            hintText: 'Search recipes, tags, ingredients...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.primary),
                    onPressed: _clearSearch)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12)),
        onChanged: (value) {
          // Debounce search to avoid too many Firebase calls
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value && value.isNotEmpty) {
              _performSearch(value);
            }
          });
        },
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildTagChip(String label, {IconData? icon, bool isPopularTag = false}) => ActionChip(
        backgroundColor: isPopularTag 
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.primary.withOpacity(0.1),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: isPopularTag ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () => _searchByTag(label),
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
            Text('Try different keywords, tags, or ingredients',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary.withOpacity(0.7))),
          ],
        ),
      );

  Widget _buildCategoryCard(String title, IconData icon) => GestureDetector(
        onTap: () => _searchByTag(title),
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

  Widget _buildLoadingIndicator() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Searching recipes...', 
                 style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
      );

  Widget _buildSearchResults() {
    if (_isLoading) return _buildLoadingIndicator();
    
    if (_searchResults.isEmpty) return _buildNoResults();
    
    return Column(
      children: [
        // Search result count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Found ${_searchResults.length} recipe${_searchResults.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) => RecipeCard(
              recipe: _searchResults[index],
              onTap: () => Navigator.pushNamed(context, '/recipe',
                  arguments: {'recipeId': _searchResults[index].id}),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Popular Tags'),
        const SizedBox(height: 12),
        if (_popularTags.isEmpty)
          const Center(child: CircularProgressIndicator(color: AppColors.primary))
        else
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularTags
                  .map((t) => _buildTagChip(t, isPopularTag: true))
                  .toList()),
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
