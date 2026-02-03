import 'package:json_annotation/json_annotation.dart';

part 'difficulty_wise_review_per_test_model.g.dart';

@JsonSerializable()
class TestReviewAnalytics {
  String analyticsType;
  @JsonKey(name: "total_questions_in_test")
  int totalQuestionsInTest;
  @JsonKey(name: "attempted_count")
  int attemptedCount;
  @JsonKey(name: "correct_count")
  int correctCount;
  @JsonKey(name: "incorrect_count")
  int incorrectCount;

  TestReviewAnalytics({
    required this.analyticsType,
    required this.totalQuestionsInTest,
    required this.attemptedCount,
    required this.correctCount,
    required this.incorrectCount,
  });

  /// 🔹 Difficulty JSON
  factory TestReviewAnalytics.fromDifficultyJson(Map<String, dynamic> json) {
    return TestReviewAnalytics(
      analyticsType: json['difficulty_level'] as String,
      totalQuestionsInTest: json['total_questions_in_test'],
      attemptedCount: json['attempted_count'],
      correctCount: json['correct_count'],
      incorrectCount: json['incorrect_count'],
    );
  }

  /// 🔹 Question type JSON
  factory TestReviewAnalytics.fromQuestionTypeJson(Map<String, dynamic> json) {
    return TestReviewAnalytics(
      analyticsType: json['question_type'] as String,
      totalQuestionsInTest: json['total_questions_in_test'],
      attemptedCount: json['attempted_count'],
      correctCount: json['correct_count'],
      incorrectCount: json['incorrect_count'],
    );
  }

  Map<String, dynamic> toJson() => _$TestReviewAnalyticsToJson(this);
}
