import 'package:hive/hive.dart';

part 'prelims_test_progress.g.dart';

@HiveType(typeId: 3)
class PrelimsTestProgress extends HiveObject {
  @HiveField(0)
  final int userId;

  @HiveField(1)
  final int testId;

  @HiveField(2)
  final String languageCode;

  @HiveField(3)
  final int currentQuestionIndex;

  @HiveField(4)
  final List<String?> selectedOptions;

  @HiveField(5)
  final List<bool> answeredStatus;

  @HiveField(6)
  final int remainingTimeInSeconds;

  @HiveField(7)
  final String savedAt;

  @HiveField(8)
  final int totalQuestions;

  PrelimsTestProgress({
    required this.userId,
    required this.testId,
    required this.languageCode,
    required this.currentQuestionIndex,
    required this.selectedOptions,
    required this.answeredStatus,
    required this.remainingTimeInSeconds,
    required this.savedAt,
    required this.totalQuestions,
  });

  bool isExpired({int maxHours = 24}) {
    final savedTime = DateTime.parse(savedAt);
    return DateTime.now().difference(savedTime).inHours >= maxHours;
  }
}
