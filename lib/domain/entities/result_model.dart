import 'package:json_annotation/json_annotation.dart';

part 'result_model.g.dart';

@JsonSerializable()
class TestResultModel {
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "test_id")
  int testId;
  @JsonKey(name: "total_questions")
  int totalQuestions;

  @JsonKey(name: "correct_answers")
  int correctAnswers;
  @JsonKey(name: "incorrect_answers")
  int inCorrectAnswers;
  @JsonKey(name: "attempted_questions")
  int attemptedQuestions;
  @JsonKey(name: "not_attempted_questions")
  int notAttemptedQuestions;
  @JsonKey(name: "score")
  double score;
  @JsonKey(name: "time_taken")
  int timeTaken;

  TestResultModel({
    required this.userId,
    required this.testId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.inCorrectAnswers,
    required this.attemptedQuestions,
    required this.notAttemptedQuestions,
    required this.score,
    required this.timeTaken,
  });

  /// ✅ copyWith method
  TestResultModel copyWith({
    int? userId,
    int? testId,
    int? totalQuestions,
    int? correctAnswers,
    int? inCorrectAnswers,
    int? attemptedQuestions,
    int? notAttemptedQuestions,
    double? score,
    int? timeTaken,
  }) {
    return TestResultModel(
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      inCorrectAnswers: inCorrectAnswers ?? this.inCorrectAnswers,
      attemptedQuestions: attemptedQuestions ?? this.attemptedQuestions,
      notAttemptedQuestions:
          notAttemptedQuestions ?? this.notAttemptedQuestions,
      score: score ?? this.score,
      timeTaken: timeTaken ?? this.timeTaken,
    );
  }

  factory TestResultModel.fromJson(Map<String, dynamic> json) =>
      _$TestResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$TestResultModelToJson(this);
}
