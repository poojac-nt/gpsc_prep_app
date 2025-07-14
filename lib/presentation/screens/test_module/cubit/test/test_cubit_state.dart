import '../../../../../domain/entities/question_language_model.dart';

class TestCubitSubmitted {
  final int? totalQuestions;
  final int? attempted;
  final int? notAttempted;
  final int? correct;
  final int? inCorrect;
  final bool isReview;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool?> isCorrect;
  final double? score;
  final int? timeSpent;
  final List<bool> answeredStatus;

  factory TestCubitSubmitted.initial() => TestCubitSubmitted();

  TestCubitSubmitted({
    this.totalQuestions,
    this.attempted,
    this.notAttempted,
    this.correct,
    this.inCorrect,
    this.questions = const [],
    this.selectedOption = const [],
    this.answeredStatus = const [],
    this.isReview = false,
    this.timeSpent,
    this.score,
    this.isCorrect = const [],
  });

  TestCubitSubmitted copyWith({
    int? totalQuestions,
    int? attempted,
    int? notAttempted,
    int? correct,
    int? inCorrect,
    bool? isReview,
    List<QuestionLanguageData>? questions,
    List<String?>? selectedOption,
    List<bool?>? isCorrect,
    double? score,
    int? timeSpent,
    List<bool>? answeredStatus,
  }) {
    return TestCubitSubmitted(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attempted: attempted ?? this.attempted,
      notAttempted: notAttempted ?? this.notAttempted,
      correct: correct ?? this.correct,
      inCorrect: inCorrect ?? this.inCorrect,
      isReview: isReview ?? this.isReview,
      questions: questions ?? this.questions,
      selectedOption: selectedOption ?? this.selectedOption,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      timeSpent: timeSpent ?? this.timeSpent,
      answeredStatus: answeredStatus ?? this.answeredStatus,
    );
  }
}
