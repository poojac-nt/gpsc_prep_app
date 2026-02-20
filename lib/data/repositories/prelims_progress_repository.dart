import 'package:gpsc_prep_app/domain/entities/prelims_test_progress.dart';
import 'package:hive/hive.dart';

class PrelimsProgressRepository {
  final Box<PrelimsTestProgress> _box;

  PrelimsProgressRepository(this._box);

  /// Save current test progress
  Future<void> saveProgress(PrelimsTestProgress progress) async {
    final key = '${progress.userId}_${progress.testId}';
    await _box.put(key, progress);
  }

  /// Get saved progress for a test
  PrelimsTestProgress? getProgress(int userId, int testId) {
    final key = '${userId}_$testId';
    return _box.get(key);
  }

  /// Delete saved progress
  Future<void> deleteProgress(int userId, int testId) async {
    final key = '${userId}_$testId';
    await _box.delete(key);
  }

  /// Check if progress exists
  bool hasProgress(int userId, int testId) {
    final key = '${userId}_$testId';
    return _box.containsKey(key);
  }

  /// Get all saved progress (for debugging/cleanup)
  List<PrelimsTestProgress> getAllProgress() {
    return _box.values.toList();
  }

  /// Clean up expired progress (older than 24 hours)
  Future<void> cleanupExpired() async {
    final keysToDelete = <String>[];
    _box.toMap().forEach((key, progress) {
      if (progress.isExpired()) {
        keysToDelete.add(key);
      }
    });
    await _box.deleteAll(keysToDelete);
  }
}
