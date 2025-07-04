// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkwIC_9syfOPZiWEuutUS2oxGiCovZUOg',
    appId: '1:846109095374:web:7dac72defbe2996ba2679f',
    messagingSenderId: '846109095374',
    projectId: 'recipe-app-6f86b',
    authDomain: 'recipe-app-6f86b.firebaseapp.com',
    storageBucket: 'recipe-app-6f86b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkwIC_9syfOPZiWEuutUS2oxGiCovZUOg',
    appId: '1:846109095374:android:7dac72defbe2996ba2679f',
    messagingSenderId: '846109095374',
    projectId: 'recipe-app-6f86b',
    storageBucket: 'recipe-app-6f86b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkwIC_9syfOPZiWEuutUS2oxGiCovZUOg',
    appId: '1:846109095374:ios:7dac72defbe2996ba2679f',
    messagingSenderId: '846109095374',
    projectId: 'recipe-app-6f86b',
    storageBucket: 'recipe-app-6f86b.firebasestorage.app',
    iosBundleId: 'com.company.recipeApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDkwIC_9syfOPZiWEuutUS2oxGiCovZUOg',
    appId: '1:846109095374:macos:7dac72defbe2996ba2679f',
    messagingSenderId: '846109095374',
    projectId: 'recipe-app-6f86b',
    storageBucket: 'recipe-app-6f86b.firebasestorage.app',
    iosBundleId: 'com.company.recipeApp',
  );
}
