import 'package:json_annotation/json_annotation.dart';

import 'difficulty_wise_review_per_test_model.dart';

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

  @JsonKey(name: "score", fromJson: _toDouble)
  final double score;

  @JsonKey(name: "time_taken")
  final int timeTaken;

  @JsonKey(name: "top_score", fromJson: _toDouble)
  final double topScore;

  @JsonKey(name: "user_rank")
  final int userRank;

  @JsonKey(name: "subject_wise_review", fromJson: _subjectWiseReviewFromJson)
  final List<TestReviewAnalytics>? subjectWiseReview;

  @JsonKey(name: "question_type_review", fromJson: _questionTypeReviewFromJson)
  final List<TestReviewAnalytics>? questionTypeReview;

  @JsonKey(
    name: "difficulty_wise_review",
    fromJson: _difficultyWiseReviewFromJson,
  )
  final List<TestReviewAnalytics>? difficultyWiseReview;

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
    required this.userRank,
    this.subjectWiseReview,
    this.questionTypeReview,
    this.difficultyWiseReview,
  });

  static double _toDouble(dynamic value) => (value as num).toDouble();

  static List<TestReviewAnalytics>? _subjectWiseReviewFromJson(dynamic json) {
    if (json == null) return null;

    if (json is List) {
      return json
          .map(
            (e) =>
                TestReviewAnalytics.fromSubjectJson(e as Map<String, dynamic>),
          )
          .toList();
    }

    if (json is Map) {
      return json.entries.map((entry) {
        return TestReviewAnalytics.fromSubjectJson({
          "name": entry.key,
          ...Map<String, dynamic>.from(entry.value),
        });
      }).toList();
    }

    return null;
  }

  static List<TestReviewAnalytics>? _questionTypeReviewFromJson(dynamic json) {
    if (json == null) return null;

    if (json is List) {
      return json
          .map(
            (e) => TestReviewAnalytics.fromQuestionTypeJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    if (json is Map) {
      return json.entries.map((entry) {
        return TestReviewAnalytics.fromQuestionTypeJson({
          "name": entry.key,
          ...Map<String, dynamic>.from(entry.value),
        });
      }).toList();
    }

    return null;
  }

  static List<TestReviewAnalytics>? _difficultyWiseReviewFromJson(
    dynamic json,
  ) {
    if (json == null) return null;

    if (json is List) {
      return json
          .map(
            (e) => TestReviewAnalytics.fromDifficultyJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    if (json is Map) {
      return json.entries.map((entry) {
        return TestReviewAnalytics.fromDifficultyJson({
          "name": entry.key,
          ...Map<String, dynamic>.from(entry.value),
        });
      }).toList();
    }

    return null;
  }

  factory TestResultWithTopScoreModel.fromJson(Map<String, dynamic> json) =>
      _$TestResultWithTopScoreModelFromJson(json);
}
