import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';

class CategoryItem {
  final String title;
  final IconData icon;
  final Color? color;

  CategoryItem({
    required this.title,
    required this.icon,
    this.color,
  });
}

class CategorySelector extends StatefulWidget {
  final List<CategoryItem> categories;
  final Function(int) onCategorySelected;
  final int initialSelected;

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
    this.initialSelected = 0,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onCategorySelected(index);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (category.color ?? AppColors.primary)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: (category.color ?? AppColors.primary)
                              .withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? (category.color ?? AppColors.primary)
                            : (category.color ?? AppColors.primary)
                                .withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      category.icon,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textPrimary.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
