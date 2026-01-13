import 'package:gpsc_prep_app/utils/enums/difficulty_level.dart';
import 'package:gpsc_prep_app/utils/enums/question_type_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'overall_analytics_model.g.dart';

@JsonSerializable()
class OverAllAnalyticsModel {
  @JsonKey(name: "difficulty")
  List<Difficulty> difficulty;
  @JsonKey(name: "question_type")
  List<Difficulty> questionType;
  @JsonKey(name: "subject_scores")
  List<SubjectScore> subjectScores;
  @JsonKey(name: "user_accuracy_overall")
  String userAccuracyOverall;

  OverAllAnalyticsModel({
    required this.difficulty,
    required this.questionType,
    required this.subjectScores,
    required this.userAccuracyOverall,
  });

  factory OverAllAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$OverAllAnalyticsModelFromJson(json);

  Map<String, dynamic> toJson() => _$OverAllAnalyticsModelToJson(this);
}

@JsonSerializable()
class Difficulty {
  @JsonKey(name: "attempted")
  int attempted;
  @JsonKey(name: "accuracy_pct")
  double accuracyPct;
  @JsonKey(name: "correct_count")
  int correctCount;
  @JsonKey(name: "not_attempted")
  int notAttempted;
  @JsonKey(name: "incorrect_count")
  int incorrectCount;
  @JsonKey(name: "total_questions")
  int totalQuestions;
  @JsonKey(name: "difficulty_level")
  DifficultyLevel? difficultyLevel;
  @JsonKey(name: "question_type")
  QuestionType? questionType;

  Difficulty({
    required this.attempted,
    required this.accuracyPct,
    required this.correctCount,
    required this.notAttempted,
    required this.incorrectCount,
    required this.totalQuestions,
    this.difficultyLevel,
    this.questionType,
  });

  factory Difficulty.fromJson(Map<String, dynamic> json) =>
      _$DifficultyFromJson(json);

  Map<String, dynamic> toJson() => _$DifficultyToJson(this);
}

@JsonSerializable()
class SubjectScore {
  @JsonKey(name: "total_score")
  double totalScore;
  @JsonKey(name: "subject_name")
  String subjectName;
  @JsonKey(name: "attempted_tests")
  int attemptedTests;
  @JsonKey(name: "total_questions")
  int totalQuestions;
  @JsonKey(name: "correct_questions")
  int correctQuestions;
  @JsonKey(name: "accuracy_percentage")
  double accuracyPercentage;
  @JsonKey(name: "attempted_questions")
  int attemptedQuestions;

  SubjectScore({
    required this.totalScore,
    required this.subjectName,
    required this.attemptedTests,
    required this.totalQuestions,
    required this.correctQuestions,
    required this.accuracyPercentage,
    required this.attemptedQuestions,
  });

  factory SubjectScore.fromJson(Map<String, dynamic> json) =>
      _$SubjectScoreFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectScoreToJson(this);
}
