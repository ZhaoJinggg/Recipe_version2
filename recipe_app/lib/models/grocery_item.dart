class GroceryItem {
  final String id;
  final String userId;
  final String? recipeId;
  final String itemName;
  final String quantity;
  final bool isChecked;
  final DateTime addedDate;

  GroceryItem({
    required this.id,
    required this.userId,
    this.recipeId,
    required this.itemName,
    required this.quantity,
    this.isChecked = false,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  GroceryItem copyWith({
    String? id,
    String? userId,
    String? recipeId,
    String? itemName,
    String? quantity,
    bool? isChecked,
    DateTime? addedDate,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipeId: recipeId ?? this.recipeId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
      'itemName': itemName,
      'quantity': quantity,
      'isChecked': isChecked,
      'addedDate': addedDate.millisecondsSinceEpoch,
    };
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      recipeId: json['recipeId'],
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] ?? '',
      isChecked: json['isChecked'] ?? false,
      addedDate: DateTime.fromMillisecondsSinceEpoch(
        json['addedDate'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
