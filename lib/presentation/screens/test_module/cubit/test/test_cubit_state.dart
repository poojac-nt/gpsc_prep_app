import '../../../../../domain/entities/question_language_model.dart';

class TestCubitSubmitted {
  final int? totalQuestions;
  final int? attemptedQuestions;
  final int? notAttemptedQuestions;
  final int? correctAnswers;
  final int? inCorrectAnswers;
  final bool isReview;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool?> isAnswerCorrect;
  final double? score;
  final int? timeSpent;
  final List<bool> answeredStatus;

  factory TestCubitSubmitted.initial() => TestCubitSubmitted();

  TestCubitSubmitted({
    this.totalQuestions,
    this.attemptedQuestions,
    this.notAttemptedQuestions,
    this.correctAnswers,
    this.inCorrectAnswers,
    this.questions = const [],
    this.selectedOption = const [],
    this.answeredStatus = const [],
    this.isReview = false,
    this.timeSpent,
    this.score,
    this.isAnswerCorrect = const [],
  });

  TestCubitSubmitted copyWith({
    int? totalQuestions,
    int? attemptedQuestions,
    int? notAttemptedQuestions,
    int? correctAnswers,
    int? inCorrectAnswers,
    bool? isReview,
    List<QuestionLanguageData>? questions,
    List<String?>? selectedOption,
    List<bool?>? isAnswerCorrect,
    double? score,
    int? timeSpent,
    List<bool>? answeredStatus,
  }) {
    return TestCubitSubmitted(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attemptedQuestions: attemptedQuestions ?? this.attemptedQuestions,
      notAttemptedQuestions:
          notAttemptedQuestions ?? this.notAttemptedQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      inCorrectAnswers: inCorrectAnswers ?? this.inCorrectAnswers,
      isReview: isReview ?? this.isReview,
      questions: questions ?? this.questions,
      selectedOption: selectedOption ?? this.selectedOption,
      isAnswerCorrect: isAnswerCorrect ?? this.isAnswerCorrect,
      score: score ?? this.score,
      timeSpent: timeSpent ?? this.timeSpent,
      answeredStatus: answeredStatus ?? this.answeredStatus,
    );
  }
}
