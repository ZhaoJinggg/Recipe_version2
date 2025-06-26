class Recipe {
  final String id;
  final String title;
  final String category;
  final String image;
  final double rating;
  final int prepTimeMinutes;
  final int servings;
  final int calories;
  final List<String> ingredients;
  final List<String> directions;
  final List<String> nutritions;
  final bool isFavorite;
  final String authorId;
  final String authorName;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.image,
    required this.rating,
    required this.prepTimeMinutes,
    required this.servings,
    required this.calories,
    required this.ingredients,
    required this.directions,
    required this.nutritions,
    this.isFavorite = false,
    required this.authorId,
    required this.authorName,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    double? rating,
    int? prepTimeMinutes,
    int? servings,
    int? calories,
    List<String>? ingredients,
    List<String>? directions,
    List<String>? nutritions,
    bool? isFavorite,
    String? authorId,
    String? authorName,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      image: this.image,
      rating: rating ?? this.rating,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      directions: directions ?? this.directions,
      nutritions: nutritions ?? this.nutritions,
      isFavorite: isFavorite ?? this.isFavorite,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
    );
  }
} 