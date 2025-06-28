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
  final DateTime dateCreated;
  final String? description;
  final String? difficultyLevel;
  final double? fat;
  final double? protein;
  final double? carbs;
  final List<String> tags;

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
    DateTime? dateCreated,
    this.description,
    this.difficultyLevel,
    this.fat,
    this.protein,
    this.carbs,
    this.tags = const [],
  }) : dateCreated = dateCreated ?? DateTime.now();

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
    DateTime? dateCreated,
    String? description,
    String? difficultyLevel,
    double? fat,
    double? protein,
    double? carbs,
    List<String>? tags,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      image: image,
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
      dateCreated: dateCreated ?? this.dateCreated,
      description: description ?? this.description,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      fat: fat ?? this.fat,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'image': image,
      'rating': rating,
      'prepTimeMinutes': prepTimeMinutes,
      'servings': servings,
      'calories': calories,
      'ingredients': ingredients,
      'directions': directions,
      'nutritions': nutritions,
      'isFavorite': isFavorite,
      'authorId': authorId,
      'authorName': authorName,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'description': description,
      'difficultyLevel': difficultyLevel,
      'fat': fat,
      'protein': protein,
      'carbs': carbs,
      'tags': tags,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      prepTimeMinutes: json['prepTimeMinutes'] ?? 0,
      servings: json['servings'] ?? 1,
      calories: json['calories'] ?? 0,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      directions: List<String>.from(json['directions'] ?? []),
      nutritions: List<String>.from(json['nutritions'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      dateCreated: DateTime.fromMillisecondsSinceEpoch(
          json['dateCreated'] ?? DateTime.now().millisecondsSinceEpoch),
      description: json['description'],
      difficultyLevel: json['difficultyLevel'],
      fat: json['fat']?.toDouble(),
      protein: json['protein']?.toDouble(),
      carbs: json['carbs']?.toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
