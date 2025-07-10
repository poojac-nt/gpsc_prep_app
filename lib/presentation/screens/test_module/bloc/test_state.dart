import '../../../../core/error/failure.dart';
import '../../../../domain/entities/question_language_model.dart';

sealed class QuestionState {}

class QuestionLoading extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<QuestionLanguageData> questions;
  final int currentIndex;
  final List<bool> answeredStatus;
  final List<String?> selectedOption;
  final bool isReview;
  final List<String> questionType;
  List<bool?>? isCorrect;

  QuestionLoaded({
    required this.questions,
    required this.questionType,
    required this.currentIndex,
    required this.answeredStatus,
    required this.selectedOption,
    this.isCorrect,
    this.isReview = false,
  });

  double get progress =>
      questions.length <= 1 ? 1.0 : currentIndex + 1 / questions.length;

  int get answered => answeredStatus.where((value) => value).toList().length;

  List<String> get options => questions[currentIndex].getOptions();

  String? get currentSelected => selectedOption[currentIndex];

  QuestionLoaded copyWith({
    List<QuestionLanguageData>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<String?>? selectedOption,
    bool? isReview,
    List<String>? questionType,
    List<bool?>? isCorrect,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      isReview: isReview ?? this.isReview,
      questionType: questionType ?? this.questionType,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

class QuestionLoadFailed extends QuestionState {
  final Failure failure;

  QuestionLoadFailed(this.failure);
}

class TestSubmitted extends QuestionState {
  final int totalQuestions;
  final int attempted;
  final int notAttempted;
  final int correct;
  final int inCorrect;
  final bool isReview;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool?> isCorrect;
  final List<bool> answeredStatus;
  final List<String> questionType;

  TestSubmitted({
    required this.totalQuestions,
    required this.attempted,
    required this.notAttempted,
    required this.correct,
    required this.inCorrect,
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
    required this.isReview,
    required this.questionType,
    required this.isCorrect,
  });
}
