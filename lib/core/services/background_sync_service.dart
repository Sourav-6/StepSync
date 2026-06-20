import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health/health.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/steps/data/datasources/steps_remote_datasource.dart';
import 'package:step_sync/features/steps/data/models/daily_steps_model.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Only run on Android for now
      if (!Platform.isAndroid) return true;

      // RULE 1: Only execute if it's late at night (After 10:00 PM)
      final now = DateTime.now();
      if (now.hour < 22) {
        return true; // Return true to indicate successful execution (but we skipped doing heavy work)
      }

      final prefs = await SharedPreferences.getInstance();
      final todayStr = Formatters.formatDateKey(now);
      
      // RULE 2: Check if we already synced late tonight to avoid duplicate writes
      final lastSyncDate = prefs.getString('bg_last_sync_date');
      final lastSyncSteps = prefs.getInt('bg_last_sync_steps') ?? 0;
      
      // Initialize Firebase (required for background isolate)
      await Firebase.initializeApp();
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return true; // No user logged in
      }

      // Fetch today's steps from Health Connect
      final health = Health();
      final types = [HealthDataType.STEPS];
      
      final hasPermissions = await health.hasPermissions(types);
      if (hasPermissions != true) {
        return true; // No background permissions granted
      }

      final midnight = DateTime(now.year, now.month, now.day);
      int? steps = await health.getTotalStepsInInterval(midnight, now);
      final currentSteps = steps ?? 0;

      // RULE 3: Only write to Firebase if steps have increased
      if (lastSyncDate == todayStr && currentSteps <= lastSyncSteps) {
        return true; // No new steps to sync
      }

      // We have new steps and it's late. Sync to Firebase.
      final remoteDataSource = StepsRemoteDataSource();
      final dailySteps = DailyStepsModel(
        uid: currentUser.uid,
        date: todayStr,
        steps: currentSteps,
        distance: currentSteps * 0.000762, // Approximate distance
        calories: currentSteps * 0.04, // Approximate calories
      );

      await remoteDataSource.saveDailySteps(dailySteps);

      // Save sync status to prevent multiple syncs tonight
      await prefs.setString('bg_last_sync_date', todayStr);
      await prefs.setInt('bg_last_sync_steps', currentSteps);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Background Sync Error: $e");
      }
      return false; // Tells WorkManager to retry later
    }
  });
}

class BackgroundSyncService {
  static const String _syncTaskName = "com.step_sync.background_step_sync";

  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic task (runs every 6 hours, but logic ensures it only writes at night)
    await Workmanager().registerPeriodicTask(
      "1", // Unique ID
      _syncTaskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
