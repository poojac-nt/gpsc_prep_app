import 'package:json_annotation/json_annotation.dart';

part 'difficulty_wise_review_per_test_model.g.dart';

@JsonSerializable()
class TestReviewByDifficulty {
  @JsonKey(name: "difficulty_level")
  String difficultyLevel;
  @JsonKey(name: "total_questions_in_test")
  int totalQuestionsInTest;
  @JsonKey(name: "attempted_count")
  int attemptedCount;
  @JsonKey(name: "correct_count")
  int correctCount;
  @JsonKey(name: "incorrect_count")
  int incorrectCount;

  TestReviewByDifficulty({
    required this.difficultyLevel,
    required this.totalQuestionsInTest,
    required this.attemptedCount,
    required this.correctCount,
    required this.incorrectCount,
  });

  factory TestReviewByDifficulty.fromJson(Map<String, dynamic> json) =>
      _$TestReviewByDifficultyFromJson(json);

  Map<String, dynamic> toJson() => _$TestReviewByDifficultyToJson(this);
}
