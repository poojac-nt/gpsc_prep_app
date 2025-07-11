import 'package:json_annotation/json_annotation.dart';

part 'result_model.g.dart';

@JsonSerializable()
class TestResultModel {
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "test_id")
  int testId;
  @JsonKey(name: "correct_answers")
  int correctAnswers;
  @JsonKey(name: "incorrect_answers")
  int inCorrectAnswers;
  @JsonKey(name: "attempted_questions")
  int attemptedQuestions;
  @JsonKey(name: "not_attempted_questions")
  int notAttemptedQuestions;
  @JsonKey(name: "total_marks")
  double totalMarks;
  @JsonKey(name: "time_taken")
  int timeTaken;

  TestResultModel({
    required this.userId,
    required this.testId,
    required this.correctAnswers,
    required this.inCorrectAnswers,
    required this.attemptedQuestions,
    required this.notAttemptedQuestions,
    required this.totalMarks,
    required this.timeTaken,
  });

  /// ✅ copyWith method
  TestResultModel copyWith({
    int? userId,
    int? testId,
    int? correctAnswers,
    int? inCorrectAnswers,
    int? attemptedQuestions,
    int? notAttemptedQuestions,
    double? totalMarks,
    int? timeTaken,
  }) {
    return TestResultModel(
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      inCorrectAnswers: inCorrectAnswers ?? this.inCorrectAnswers,
      attemptedQuestions: attemptedQuestions ?? this.attemptedQuestions,
      notAttemptedQuestions:
          notAttemptedQuestions ?? this.notAttemptedQuestions,
      totalMarks: totalMarks ?? this.totalMarks,
      timeTaken: timeTaken ?? this.timeTaken,
    );
  }

  factory TestResultModel.fromJson(Map<String, dynamic> json) =>
      _$TestResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$TestResultModelToJson(this);
}
