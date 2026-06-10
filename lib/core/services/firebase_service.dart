import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Service for initializing and managing Firebase.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Initialize Firebase with the default options.
  /// Call this in main() before runApp().
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        // Firebase options will be configured when google-services.json
        // and GoogleService-Info.plist are added to the project.
        // For FlutterFire CLI setup, uncomment and use:
        // options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Check if Firebase is initialized.
  static bool get isInitialized => _initialized;
}
