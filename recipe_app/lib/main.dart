import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/screens/home_screen.dart';
import 'package:recipe_app/screens/recipe_detail_screen.dart';
import 'package:recipe_app/screens/favorites_screen.dart';
import 'package:recipe_app/screens/profile_screen.dart';
import 'package:recipe_app/screens/edit_profile_screen.dart';
import 'package:recipe_app/screens/settings_screen.dart';
import 'package:recipe_app/screens/grocery_list_screen.dart';
import 'package:recipe_app/screens/login_screen.dart';
import 'package:recipe_app/screens/settings_screen.dart';
import 'package:recipe_app/screens/signup_screen.dart';
import 'package:recipe_app/screens/community_screen.dart';
import 'package:recipe_app/screens/search_screen.dart';
import 'package:recipe_app/screens/help_support_screen.dart';
import 'package:recipe_app/screens/upload_recipe_screen.dart';
import 'package:recipe_app/screens/my_recipes_screen.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe_app/firebase_options.dart';
import 'package:recipe_app/services/data_migration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await UserSessionService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      // Check if user is logged in to determine initial route
      initialRoute:
          UserSessionService.getCurrentUser() != null ? '/' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/': (context) => const HomeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/grocery': (context) => const GroceryListScreen(),
        '/community': (context) => const CommunityScreen(),
        '/search': (context) => const SearchScreen(),
        '/help_support': (context) => const HelpSupportScreen(),
        '/upload-recipe': (context) => const UploadRecipeScreen(),
        '/my-recipes': (context) => const MyRecipesScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/recipe') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return RecipeDetailScreen(recipeId: args['recipeId']);
            },
          );
        }
        return null;
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
      ],
    );
  }
}
