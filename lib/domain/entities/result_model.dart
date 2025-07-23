import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'result_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class TestResultModel {
  @JsonKey(name: "user_id")
  @HiveField(0)
  int userId;
  @JsonKey(name: "test_id")
  @HiveField(1)
  int testId;
  @JsonKey(name: "total_questions")
  @HiveField(2)
  int totalQuestions;
  @JsonKey(name: "correct_answers")
  @HiveField(3)
  int correctAnswers;
  @JsonKey(name: "incorrect_answers")
  @HiveField(4)
  int inCorrectAnswers;
  @JsonKey(name: "attempted_questions")
  @HiveField(5)
  int attemptedQuestions;
  @JsonKey(name: "not_attempted_questions")
  @HiveField(6)
  int notAttemptedQuestions;
  @JsonKey(name: "score")
  @HiveField(7)
  double score;
  @JsonKey(name: "time_taken")
  @HiveField(8)
  int timeTaken;
  @JsonKey(name: "created_at")
  @HiveField(9)
  String? createdAt;

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
    this.createdAt,
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
    String? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TestResultModel.fromJson(Map<String, dynamic> json) =>
      _$TestResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$TestResultModelToJson(this);
}
