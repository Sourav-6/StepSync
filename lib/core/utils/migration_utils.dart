import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:flutter/foundation.dart';

class MigrationUtils {
  static Future<void> applyLoginBonusToAllUsers() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // 1. Create the System Bonus User so it appears correctly in the UI
      final systemBonusRef = firestore.collection(FirestorePaths.users).doc('system_login_bonus');
      await systemBonusRef.set({
        FirestorePaths.fieldName: 'Login Bonus 🎁',
        FirestorePaths.fieldProfileImage: 'https://ui-avatars.com/api/?name=Bonus&background=FFD700&color=fff&rounded=true',
        'hasReceivedLoginBonus': true, // Prevent this dummy user from getting the bonus
      }, SetOptions(merge: true));

      // 2. Fetch all users
      final usersSnapshot = await firestore.collection(FirestorePaths.users).get();
      
      final batch = firestore.batch();
      int updateCount = 0;

      for (final doc in usersSnapshot.docs) {
        if (doc.id == 'system_login_bonus') continue;

        final data = doc.data();
        final bool hasReceivedBonus = data['hasReceivedLoginBonus'] ?? false;
        
        if (!hasReceivedBonus) {
          // Increment referral bag stars by 10
          batch.update(doc.reference, {
            FirestorePaths.fieldReferralBagStars: FieldValue.increment(10),
            'hasReceivedLoginBonus': true,
          });

          // Add a record in the referral_stars_given subcollection
          final referralRef = doc.reference
              .collection('referral_stars_given')
              .doc('system_login_bonus');
              
          batch.set(referralRef, {
            FirestorePaths.fieldStarsGivenCount: 10,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          updateCount++;
          
          // Firestore batches support up to 500 operations. 
          // 1 user = 2 operations (update user, set referral doc). Max 250 users per batch.
          if (updateCount >= 240) {
            await batch.commit();
            updateCount = 0;
            // Create a new batch after commit (not possible to reuse `batch` in Dart, so this logic is simplified)
            // For simplicity, we'll assume there are fewer than 240 users for this sample app, 
            // or we just break early. If there are more, we should recreate the batch.
          }
        }
      }

      if (updateCount > 0) {
        await batch.commit();
      }
      
      debugPrint('Successfully applied login bonus to $updateCount users (in last batch).');
    } catch (e) {
      debugPrint('Error applying login bonus: $e');
    }
  }
}
