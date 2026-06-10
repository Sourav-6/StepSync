import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/app.dart';
import 'package:step_sync/core/services/firebase_service.dart';
import 'package:step_sync/core/services/hive_service.dart';

/// Application entry point.
/// Initializes Firebase, Hive, and system UI before launching the app.
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await HiveService.initialize();
  await FirebaseService.initialize();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: StepSyncApp(),
    ),
  );
}
