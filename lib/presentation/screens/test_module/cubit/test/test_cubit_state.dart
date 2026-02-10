import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';

import '../../../../../domain/entities/question_language_model.dart';

class TestCubitSubmitted {
  final int? totalQuestions;
  final int? attemptedQuestions;
  final int? notAttemptedQuestions;
  final int? correctAnswers;
  final int? inCorrectAnswers;
  final bool isReview;
  final List<QuestionModel> questionsModel;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool?> isAnswerCorrect;
  final double? score;
  final double? topScore;
  final int? timeSpent;
  final List<bool> answeredStatus;
  final int? userRank;
  final List<DetailedTestResult> batchResults;
  final List<int>? timePerQuestion;

  factory TestCubitSubmitted.initial() => TestCubitSubmitted();

  TestCubitSubmitted({
    this.totalQuestions,
    this.attemptedQuestions,
    this.notAttemptedQuestions,
    this.correctAnswers,
    this.inCorrectAnswers,
    this.questionsModel = const [],
    this.questions = const [],
    this.selectedOption = const [],
    this.answeredStatus = const [],
    this.isReview = false,
    this.timeSpent,
    this.score,
    this.topScore,
    this.userRank,
    this.isAnswerCorrect = const [],
    this.batchResults = const [],
    this.timePerQuestion,
  });

  TestCubitSubmitted copyWith({
    int? totalQuestions,
    int? attemptedQuestions,
    int? notAttemptedQuestions,
    int? correctAnswers,
    int? inCorrectAnswers,
    bool? isReview,
    List<QuestionModel>? questionsModel,
    List<QuestionLanguageData>? questions,
    List<String?>? selectedOption,
    List<bool?>? isAnswerCorrect,
    double? score,
    int? timeSpent,
    List<bool>? answeredStatus,
    int? userRank,
    List<DetailedTestResult>? batchResults,
    List<int>? timePerQuestion,
  }) {
    return TestCubitSubmitted(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attemptedQuestions: attemptedQuestions ?? this.attemptedQuestions,
      notAttemptedQuestions:
          notAttemptedQuestions ?? this.notAttemptedQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      inCorrectAnswers: inCorrectAnswers ?? this.inCorrectAnswers,
      isReview: isReview ?? this.isReview,
      questionsModel: questionsModel ?? this.questionsModel,
      questions: questions ?? this.questions,
      selectedOption: selectedOption ?? this.selectedOption,
      isAnswerCorrect: isAnswerCorrect ?? this.isAnswerCorrect,
      score: score ?? this.score,
      timeSpent: timeSpent ?? this.timeSpent,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      userRank: userRank ?? this.userRank,
      batchResults: batchResults ?? this.batchResults,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
    );
  }
}
