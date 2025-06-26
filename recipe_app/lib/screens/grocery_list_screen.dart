import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';
import 'package:recipe_app/models/grocery_item.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/user_session_service.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({Key? key}) : super(key: key);

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final int _currentNavIndex = -1; // No bottom nav tab selected
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String _selectedCategory = 'Produce';
  List<GroceryItem> _groceryItems = [];

  final List<String> _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Pantry',
    'Frozen',
    'Beverages',
    'Spices',
    'Bakery',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchGroceryList();
  }

  bool get _isLoggedIn => UserSessionService.getCurrentUser() != null;

  Future<void> _fetchGroceryList() async {
    setState(() => _isLoading = true);
    final user = UserSessionService.getCurrentUser();
    if (user == null) {
      setState(() {
        _groceryItems = [];
        _isLoading = false;
      });
      return;
    }
    final items = await FirebaseService.getGroceryListForUser(user.id);
    setState(() {
      _groceryItems = items;
      _isLoading = false;
    });
  }

  Map<String, List<GroceryItem>> get _groupedItems {
    final Map<String, List<GroceryItem>> grouped = {};
    for (final item in _groceryItems) {
      final category = item.quantity.isNotEmpty ? item.quantity : 'Other';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }
    return grouped;
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Grocery Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter item name',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (optional)',
                    hintText: 'e.g., 2 cups, 500g',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addItem() async {
    final user = UserSessionService.getCurrentUser();
    if (user == null || _itemController.text.trim().isEmpty) return;
    final newItem = GroceryItem(
      id: '',
      userId: user.id,
      itemName: _itemController.text.trim(),
      quantity: _amountController.text.trim(),
      isChecked: false,
      addedDate: DateTime.now(),
    );
    await FirebaseService.addGroceryItem(newItem);
    _itemController.clear();
    _amountController.clear();
    Navigator.pop(context);
    _fetchGroceryList();
  }

  Future<void> _removeItem(String id) async {
    await FirebaseService.deleteGroceryItem(id);
    _fetchGroceryList();
  }

  Future<void> _toggleItemChecked(GroceryItem item) async {
    final updated = item.copyWith(isChecked: !item.isChecked);
    await FirebaseService.updateGroceryItem(updated);
    _fetchGroceryList();
  }

  @override
  void dispose() {
    _itemController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text(
            'My Grocery List',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Please log in to access your grocery list.',
                style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'My Grocery List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.delete_outline, color: AppColors.textPrimary),
            onPressed: () async {
              final checkedItems =
                  _groceryItems.where((item) => item.isChecked).toList();
              for (final item in checkedItems) {
                await FirebaseService.deleteGroceryItem(item.id);
              }
              _fetchGroceryList();
            },
            tooltip: 'Remove checked items',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groceryItems.isEmpty
              ? _buildEmptyState()
              : _buildGroceryList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/favorites');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your grocery list is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your shopping list',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showAddItemDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add Items'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroceryList() {
    return ListView.builder(
      itemCount: _groceryItems.length,
      itemBuilder: (context, index) {
        final item = _groceryItems[index];
        return Dismissible(
          key: Key(item.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _removeItem(item.id);
          },
          child: ListTile(
            title: Text(
              item.itemName,
              style: TextStyle(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked
                    ? AppColors.textPrimary.withOpacity(0.6)
                    : AppColors.textPrimary,
                fontWeight:
                    item.isChecked ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: item.quantity.isNotEmpty
                ? Text(
                    item.quantity,
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  )
                : null,
            leading: Checkbox(
              value: item.isChecked,
              onChanged: (value) {
                _toggleItemChecked(item);
              },
              activeColor: AppColors.primary,
              checkColor: AppColors.textPrimary,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeItem(item.id),
            ),
          ),
        );
      },
    );
  }
}
