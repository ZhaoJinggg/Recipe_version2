import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppColors {
  static const Color primary = Color(0xFFF8C91C); // Dark Yellow: F8C91C
  static const Color primaryLight = Color(0xFFFFFFEB); // Light Yellow: FFFFEB
  static const Color accent =
      Color(0xFFF8C91C); // Using Dark Yellow for accent too
  static const Color background = Color(0xFFFFFFEB); // Light Yellow: FFFFEB
  static const Color textPrimary = Color(0xFF024943); // Words: 024943
  static const Color textSecondary = Color(0xFF024943); // Words: 024943
  static const Color divider = Color(0xFFF8C91C);

  static var border; // Dark Yellow: F8C91C
}

class FoodCategories {
  static final List<CategoryData> categories = [
    CategoryData(
      id: 'all',
      title: 'All',
      icon: FontAwesomeIcons.list,
      color: Color(0xFFF8C91C),
    ),
    CategoryData(
      id: 'appetizers',
      title: 'Appetizers',
      icon: FontAwesomeIcons.utensils,
      color: Colors.redAccent,
    ),
    CategoryData(
      id: 'soups',
      title: 'Soups',
      icon: FontAwesomeIcons.bowlFood,
      color: Colors.orangeAccent,
    ),
    CategoryData(
      id: 'salads',
      title: 'Salads',
      icon: FontAwesomeIcons.leaf,
      color: Colors.greenAccent,
    ),
    CategoryData(
      id: 'main course',
      title: 'Main Course',
      icon: FontAwesomeIcons.drumstickBite,
      color: Colors.blueAccent,
    ),
    CategoryData(
      id: 'dessert',
      title: 'Dessert',
      icon: FontAwesomeIcons.iceCream,
      color: Colors.purpleAccent,
    ),
  ];

  static CategoryData getById(String id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => categories[0],
    );
  }
}

class CategoryData {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  CategoryData({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.background,
        onPrimary: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
    );
  }
}
