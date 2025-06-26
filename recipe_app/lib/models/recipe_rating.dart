class RecipeRating {
  final String id;
  final String userId;
  final String recipeId;
  final double rating;
  final String? review;
  final DateTime dateCreated;

  RecipeRating({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.rating,
    this.review,
    DateTime? dateCreated,
  }) : dateCreated = dateCreated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
      'rating': rating,
      'review': review,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
    };
  }

  factory RecipeRating.fromJson(Map<String, dynamic> json) {
    return RecipeRating(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      recipeId: json['recipeId'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      review: json['review'],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(
        json['dateCreated'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
