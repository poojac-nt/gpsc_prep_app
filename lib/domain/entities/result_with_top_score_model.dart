import 'package:json_annotation/json_annotation.dart';

part 'result_with_top_score_model.g.dart';

@JsonSerializable()
class TestResultWithTopScoreModel {
  @JsonKey(name: "user_id")
  final int userId;

  @JsonKey(name: "test_id")
  final int testId;

  @JsonKey(name: "total_questions")
  final int totalQuestions;

  @JsonKey(name: "correct_answers")
  final int correctAnswers;

  @JsonKey(name: "incorrect_answers")
  final int inCorrectAnswers;

  @JsonKey(name: "attempted_questions")
  final int attemptedQuestions;

  @JsonKey(name: "not_attempted_questions")
  final int notAttemptedQuestions;

  @JsonKey(name: "score")
  final double score;

  @JsonKey(name: "time_taken")
  final int timeTaken;

  @JsonKey(name: "created_at")
  final String? createdAt;

  /// ✅ Only exists in RPC response
  @JsonKey(name: "top_score")
  final double topScore;

  const TestResultWithTopScoreModel({
    required this.userId,
    required this.testId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.inCorrectAnswers,
    required this.attemptedQuestions,
    required this.notAttemptedQuestions,
    required this.score,
    required this.timeTaken,
    required this.topScore,
    this.createdAt,
  });

  factory TestResultWithTopScoreModel.fromJson(Map<String, dynamic> json) =>
      _$TestResultWithTopScoreModelFromJson(json);
}
