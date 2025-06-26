import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/grocery_item.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/mock_data_service.dart';

class RecipeIngredientsWidget extends StatefulWidget {
  final Recipe recipe;

  const RecipeIngredientsWidget({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  State<RecipeIngredientsWidget> createState() =>
      _RecipeIngredientsWidgetState();
}

class _RecipeIngredientsWidgetState extends State<RecipeIngredientsWidget> {
  final Set<int> _addedToGroceryList = <int>{};

  Future<void> _addIngredientToGroceryList(String ingredient, int index) async {
    try {
      final currentUser = MockDataService.getCurrentUser();
      final groceryItem = GroceryItem(
        id: '', // Firebase will generate this
        userId: currentUser.id,
        recipeId: widget.recipe.id,
        itemName: ingredient,
        quantity: '1', // Default quantity
      );

      await FirebaseService.addGroceryItem(groceryItem);

      setState(() {
        _addedToGroceryList.add(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Added "$ingredient" to grocery list')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('Failed to add to grocery list')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.recipe.ingredients.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.withOpacity(0.3),
        ),
        itemBuilder: (context, index) {
          final ingredient = widget.recipe.ingredients[index];
          final isAdded = _addedToGroceryList.contains(index);

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ingredient,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isAdded
                      ? null
                      : () => _addIngredientToGroceryList(ingredient, index),
                  icon: Icon(
                    isAdded ? Icons.check_circle : Icons.add_shopping_cart,
                    color: isAdded ? Colors.green : AppColors.primary,
                    size: 20,
                  ),
                  tooltip:
                      isAdded ? 'Added to grocery list' : 'Add to grocery list',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
