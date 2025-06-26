// import 'package:flutter/material.dart';
// import 'package:recipe_app/constants.dart';
// import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';

// class GroceryItem {
//   final String id;
//   final String name;
//   final String? category;
//   final String? amount;
//   bool isChecked;

//   GroceryItem({
//     required this.id,
//     required this.name,
//     this.category,
//     this.amount,
//     this.isChecked = false,
//   });
// }

// class GroceryListScreen extends StatefulWidget {
//   const GroceryListScreen({Key? key}) : super(key: key);

//   @override
//   State<GroceryListScreen> createState() => _GroceryListScreenState();
// }

// class _GroceryListScreenState extends State<GroceryListScreen> {
//   final int _currentNavIndex = -1; // No bottom nav tab selected
//   final TextEditingController _itemController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   String _selectedCategory = 'Produce';

//   // Example grocery categories
//   final List<String> _categories = [
//     'Produce',
//     'Dairy',
//     'Meat',
//     'Pantry',
//     'Frozen',
//     'Beverages',
//     'Spices',
//     'Bakery',
//     'Other',
//   ];

//   // Sample data for demonstration
//   final List<GroceryItem> _groceryItems = [
//     GroceryItem(
//       id: '1',
//       name: 'Chicken breast',
//       category: 'Meat',
//       amount: '500g',
//     ),
//     GroceryItem(
//       id: '2',
//       name: 'Olive oil',
//       category: 'Pantry',
//       amount: '1 bottle',
//     ),
//     GroceryItem(
//       id: '3',
//       name: 'Red pepper flakes',
//       category: 'Spices',
//       amount: '1 tbsp',
//     ),
//     GroceryItem(
//       id: '4',
//       name: 'Soy sauce',
//       category: 'Pantry',
//       amount: '3 tbsp',
//     ),
//     GroceryItem(
//       id: '5',
//       name: 'Honey',
//       category: 'Pantry',
//       amount: '1 cup',
//     ),
//     GroceryItem(
//       id: '6',
//       name: 'Garlic',
//       category: 'Produce',
//       amount: '4 cloves',
//     ),
//     GroceryItem(
//       id: '7',
//       name: 'Rice',
//       category: 'Pantry',
//       amount: '2 cups',
//     ),
//     GroceryItem(
//       id: '8',
//       name: 'Green onions',
//       category: 'Produce',
//       amount: '1 bunch',
//     ),
//   ];

//   Map<String, List<GroceryItem>> get _groupedItems {
//     final Map<String, List<GroceryItem>> grouped = {};

//     for (final item in _groceryItems) {
//       final category = item.category ?? 'Other';
//       if (!grouped.containsKey(category)) {
//         grouped[category] = [];
//       }
//       grouped[category]!.add(item);
//     }

//     return grouped;
//   }

//   void _addItem() {
//     if (_itemController.text.trim().isEmpty) return;

//     setState(() {
//       _groceryItems.add(
//         GroceryItem(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           name: _itemController.text.trim(),
//           category: _selectedCategory,
//           amount: _amountController.text.trim().isEmpty
//               ? null
//               : _amountController.text.trim(),
//         ),
//       );
//       _itemController.clear();
//       _amountController.clear();
//     });

//     Navigator.pop(context);
//   }

//   void _removeItem(String id) {
//     setState(() {
//       _groceryItems.removeWhere((item) => item.id == id);
//     });
//   }

//   void _toggleItemChecked(String id) {
//     setState(() {
//       final item = _groceryItems.firstWhere((item) => item.id == id);
//       item.isChecked = !item.isChecked;
//     });
//   }

//   void _showAddItemDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Add Grocery Item'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _itemController,
//                   decoration: const InputDecoration(
//                     labelText: 'Item Name',
//                     hintText: 'Enter item name',
//                   ),
//                   autofocus: true,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _amountController,
//                   decoration: const InputDecoration(
//                     labelText: 'Amount (optional)',
//                     hintText: 'e.g., 2 cups, 500g',
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _selectedCategory,
//                   decoration: const InputDecoration(
//                     labelText: 'Category',
//                   ),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem(
//                       value: category,
//                       child: Text(category),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       setState(() {
//                         _selectedCategory = value;
//                       });
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: _addItem,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: AppColors.textPrimary,
//               ),
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _itemController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         title: const Text(
//           'My Grocery List',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon:
//                 const Icon(Icons.delete_outline, color: AppColors.textPrimary),
//             onPressed: () {
//               setState(() {
//                 _groceryItems.removeWhere((item) => item.isChecked);
//               });
//             },
//             tooltip: 'Remove checked items',
//           ),
//           IconButton(
//             icon: const Icon(Icons.sort, color: AppColors.textPrimary),
//             onPressed: () {
//               // TODO: Implement sorting options
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Sorting options coming soon!'),
//                   backgroundColor: AppColors.primary,
//                 ),
//               );
//             },
//             tooltip: 'Sort list',
//           ),
//         ],
//       ),
//       body: _groceryItems.isEmpty ? _buildEmptyState() : _buildGroceryList(),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primary,
//         onPressed: _showAddItemDialog,
//         child: const Icon(Icons.add, color: AppColors.textPrimary),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: _currentNavIndex,
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushReplacementNamed(context, '/home');
//           } else if (index == 3) {
//             Navigator.pushReplacementNamed(context, '/favorites');
//           } else if (index == 4) {
//             Navigator.pushReplacementNamed(context, '/profile');
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.shopping_basket_outlined,
//             size: 80,
//             color: AppColors.primary.withOpacity(0.5),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Your grocery list is empty',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Add items to your shopping list',
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textPrimary.withOpacity(0.7),
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _showAddItemDialog,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: AppColors.textPrimary,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Add Items'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGroceryList() {
//     final grouped = _groupedItems;
//     final categories = grouped.keys.toList()
//       ..sort((a, b) {
//         // Place 'Other' at the end
//         if (a == 'Other') return 1;
//         if (b == 'Other') return -1;
//         return a.compareTo(b);
//       });

//     return ListView.builder(
//       itemCount: categories.length,
//       itemBuilder: (context, index) {
//         final category = categories[index];
//         final items = grouped[category]!;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//               child: Row(
//                 children: [
//                   Icon(
//                     _getCategoryIcon(category),
//                     color: AppColors.textPrimary,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     category,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${items.length}',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ...items.map((item) => _buildGroceryItem(item)).toList(),
//             const Divider(height: 8),
//           ],
//         );
//       },
//     );
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Produce':
//         return Icons.eco;
//       case 'Dairy':
//         return Icons.egg_alt;
//       case 'Meat':
//         return Icons.restaurant;
//       case 'Pantry':
//         return Icons.kitchen;
//       case 'Frozen':
//         return Icons.ac_unit;
//       case 'Beverages':
//         return Icons.local_drink;
//       case 'Spices':
//         return Icons.spa;
//       case 'Bakery':
//         return Icons.breakfast_dining;
//       default:
//         return Icons.shopping_basket;
//     }
//   }

//   Widget _buildGroceryItem(GroceryItem item) {
//     return Dismissible(
//       key: Key(item.id),
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: const Icon(
//           Icons.delete,
//           color: Colors.white,
//         ),
//       ),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) {
//         _removeItem(item.id);
//       },
//       child: ListTile(
//         title: Text(
//           item.name,
//           style: TextStyle(
//             decoration: item.isChecked ? TextDecoration.lineThrough : null,
//             color: item.isChecked
//                 ? AppColors.textPrimary.withOpacity(0.6)
//                 : AppColors.textPrimary,
//             fontWeight: item.isChecked ? FontWeight.normal : FontWeight.bold,
//           ),
//         ),
//         subtitle: item.amount != null
//             ? Text(
//                 item.amount!,
//                 style: TextStyle(
//                   color: AppColors.textPrimary.withOpacity(0.7),
//                 ),
//               )
//             : null,
//         leading: Checkbox(
//           value: item.isChecked,
//           onChanged: (value) {
//             _toggleItemChecked(item.id);
//           },
//           activeColor: AppColors.primary,
//           checkColor: AppColors.textPrimary,
//         ),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete_outline, color: Colors.red),
//           onPressed: () => _removeItem(item.id),
//         ),
//       ),
//     );
//   }
// }
