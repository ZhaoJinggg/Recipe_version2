class Ingredient {
  final String id;
  final String name;

  Ingredient({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class RecipeIngredient {
  final String id;
  final String recipeId;
  final String ingredientId;
  final String quantity;
  final String unit;

  RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeId': recipeId,
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] ?? '',
      recipeId: json['recipeId'] ?? '',
      ingredientId: json['ingredientId'] ?? '',
      quantity: json['quantity'] ?? '',
      unit: json['unit'] ?? '',
    );
  }
}
