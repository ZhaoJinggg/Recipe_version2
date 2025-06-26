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
import 'package:firebase_core/firebase_core.dart';
// Uncomment these imports when you're ready to use Firebase
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/data_migration_service.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/services/firebase_integration_test.dart';
import 'package:recipe_app/services/auth_debug_service.dart';
import 'package:recipe_app/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    print('🚀 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Test Firebase connection
    final isConnected = await FirebaseService.testConnection();
    if (isConnected) {
      print('🔥 Firebase is ready to use!');

      // Initialize user session service
      await UserSessionService.initialize();

      // Optional: Migrate mock data to Firebase (run this once)
      // Uncomment the line below to populate Firebase with initial data
      // await DataMigrationService.migrateAllData();

      // Run integration test to verify everything is working
      // Uncomment the line below to test the complete workflow
      // await FirebaseIntegrationTest.testCompleteWorkflow();

      // Debug: Test Firebase Authentication (uncomment for debugging)
      // print('🧪 Running Firebase Auth Debug Tests...');
      // await AuthDebugService.testFirebaseConnection();
      // await AuthDebugService.testAuthWorkflow();
      // await AuthDebugService.testErrorHandling();

      // Print current authentication status
      AuthDebugService.printAuthStatus();
    } else {
      print(
          '⚠️ Firebase connection issue - app will continue with offline mode');
    }
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('🔄 App will continue without Firebase features');
  }

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
      initialRoute: UserSessionService.isLoggedIn() ? '/' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/': (context) => const HomeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        // '/grocery': (context) => const GroceryListScreen(),
        '/community': (context) => const CommunityScreen(),
        '/search': (context) => const SearchScreen(),
        '/help_support': (context) => const HelpSupportScreen(),
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
