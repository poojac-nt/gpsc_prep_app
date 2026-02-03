// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overall_analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverAllAnalyticsModel _$OverAllAnalyticsModelFromJson(
        Map<String, dynamic> json) =>
    OverAllAnalyticsModel(
      difficulty: (json['difficulty'] as List<dynamic>)
          .map((e) => Difficulty.fromJson(e as Map<String, dynamic>))
          .toList(),
      questionType: (json['question_type'] as List<dynamic>)
          .map((e) => Difficulty.fromJson(e as Map<String, dynamic>))
          .toList(),
      subjectScores: (json['subject_scores'] as List<dynamic>)
          .map((e) => SubjectScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      userAccuracyOverall: json['user_accuracy_overall'] as num,
    );

Map<String, dynamic> _$OverAllAnalyticsModelToJson(
        OverAllAnalyticsModel instance) =>
    <String, dynamic>{
      'difficulty': instance.difficulty,
      'question_type': instance.questionType,
      'subject_scores': instance.subjectScores,
      'user_accuracy_overall': instance.userAccuracyOverall,
    };

Difficulty _$DifficultyFromJson(Map<String, dynamic> json) => Difficulty(
      attempted: (json['attempted'] as num).toInt(),
      accuracyPct: (json['accuracy_pct'] as num).toDouble(),
      correctCount: (json['correct_count'] as num).toInt(),
      notAttempted: (json['not_attempted'] as num).toInt(),
      incorrectCount: (json['incorrect_count'] as num).toInt(),
      totalQuestions: (json['total_questions'] as num).toInt(),
      difficultyLevel: $enumDecodeNullable(
          _$DifficultyLevelEnumMap, json['difficulty_level']),
      questionType:
          $enumDecodeNullable(_$QuestionTypeEnumMap, json['question_type']),
    );

Map<String, dynamic> _$DifficultyToJson(Difficulty instance) =>
    <String, dynamic>{
      'attempted': instance.attempted,
      'accuracy_pct': instance.accuracyPct,
      'correct_count': instance.correctCount,
      'not_attempted': instance.notAttempted,
      'incorrect_count': instance.incorrectCount,
      'total_questions': instance.totalQuestions,
      'difficulty_level': _$DifficultyLevelEnumMap[instance.difficultyLevel],
      'question_type': _$QuestionTypeEnumMap[instance.questionType],
    };

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.easy: 'easy',
  DifficultyLevel.mod: 'mod',
  DifficultyLevel.diff: 'diff',
  DifficultyLevel.otfb: 'otfb',
};

const _$QuestionTypeEnumMap = {
  QuestionType.simple: 'simple',
  QuestionType.mtf: 'mtf',
  QuestionType.fitb: 'fitb',
  QuestionType.stmt: 'stmt',
  QuestionType.desc: 'desc',
};

SubjectScore _$SubjectScoreFromJson(Map<String, dynamic> json) => SubjectScore(
      totalScore: (json['total_score'] as num).toDouble(),
      subjectName: json['subject_name'] as String,
      attemptedTests: (json['attempted_tests'] as num).toInt(),
      totalQuestions: (json['total_questions'] as num).toInt(),
      correctQuestions: (json['correct_questions'] as num).toInt(),
      accuracyPercentage: (json['accuracy_percentage'] as num).toDouble(),
      attemptedQuestions: (json['attempted_questions'] as num).toInt(),
    );

Map<String, dynamic> _$SubjectScoreToJson(SubjectScore instance) =>
    <String, dynamic>{
      'total_score': instance.totalScore,
      'subject_name': instance.subjectName,
      'attempted_tests': instance.attemptedTests,
      'total_questions': instance.totalQuestions,
      'correct_questions': instance.correctQuestions,
      'accuracy_percentage': instance.accuracyPercentage,
      'attempted_questions': instance.attemptedQuestions,
    };
