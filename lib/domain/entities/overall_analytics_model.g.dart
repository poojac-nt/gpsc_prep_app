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
      userAccuracyOverall: _parseToDouble(json['user_accuracy_overall']),
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
      attempted: _parseToInt(json['attempted']),
      accuracyPct: _parseToDouble(json['accuracy_pct']),
      correctCount: _parseToInt(json['correct_count']),
      notAttempted: _parseToInt(json['not_attempted']),
      incorrectCount: _parseToInt(json['incorrect_count']),
      totalQuestions: _parseToInt(json['total_questions']),
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
      totalScore: _parseToDouble(json['total_score']),
      subjectName: json['subject_name'] as String,
      attemptedTests: _parseToInt(json['attempted_tests']),
      totalQuestions: _parseToInt(json['total_questions']),
      correctQuestions: _parseToInt(json['correct_questions']),
      accuracyPercentage: _parseToDouble(json['accuracy_percentage']),
      attemptedQuestions: _parseToInt(json['attempted_questions']),
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
