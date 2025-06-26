class SavedRecipe {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime savedDate;

  SavedRecipe({
    required this.id,
    required this.userId,
    required this.recipeId,
    DateTime? savedDate,
  }) : savedDate = savedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
      'savedDate': savedDate.millisecondsSinceEpoch,
    };
  }

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      recipeId: json['recipeId'] ?? '',
      savedDate: DateTime.fromMillisecondsSinceEpoch(
        json['savedDate'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
