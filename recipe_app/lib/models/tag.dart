class Tag {
  final String id;
  final String name;

  Tag({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'tag_name': name,
    };
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? '',
      name: json['tag_name'] ?? '',
    );
  }
}

class RecipeTag {
  final String id;
  final String recipeId;
  final String tagId;

  RecipeTag({
    required this.id,
    required this.recipeId,
    required this.tagId,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'tag_id': tagId,
    };
  }

  factory RecipeTag.fromJson(Map<String, dynamic> json) {
    return RecipeTag(
      id: json['id'] ?? '',
      recipeId: json['recipe_id'] ?? '',
      tagId: json['tag_id'] ?? '',
    );
  }
}
