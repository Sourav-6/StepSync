import 'package:step_sync/core/services/hive_service.dart';

/// A generic caching service backed by Hive to cache API responses and rate limit operations.
class CacheService {
  CacheService._();

  /// Save data to cache with the current timestamp.
  static Future<void> setCache(String key, dynamic data) async {
    final payload = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    };
    await HiveService.cache.put(key, payload);
  }

  /// Get data from cache if it has not expired according to the [ttl].
  /// Returns null if expired or missing.
  static dynamic getCache(String key, Duration ttl) {
    final payload = HiveService.cache.get(key);
    if (payload == null || payload is! Map) return null;

    final timestamp = payload['timestamp'] as int?;
    if (timestamp == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age < ttl.inMilliseconds) {
      return payload['data'];
    }

    // Expired
    HiveService.cache.delete(key);
    return null;
  }

  /// Helper to rate limit function calls.
  /// Returns true if an operation can proceed (i.e. if it hasn't been executed within [threshold]).
  /// If it can proceed, it automatically updates the timestamp.
  static Future<bool> canProceed(String operationKey, Duration threshold) async {
    final lastRun = HiveService.cache.get(operationKey) as int?;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastRun == null || (now - lastRun) >= threshold.inMilliseconds) {
      await HiveService.cache.put(operationKey, now);
      return true;
    }
    return false;
  }
}
