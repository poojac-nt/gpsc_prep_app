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

  QuestionLoaded({
    required this.questions,
    required this.questionType,
    required this.currentIndex,
    required this.answeredStatus,
    required this.selectedOption,
    this.isReview = false,
  });

  double get progress =>
      questions.length <= 1 ? 1.0 : currentIndex + 1 / questions.length;
  int get answered => answeredStatus.where((value) => value).toList().length;
  List<String> get options => questions[currentIndex].getOptions();
  String? get currentSelected => selectedOption[currentIndex];
  // Widget get question => questions[currentIndex].toQuestionWidget();

  QuestionLoaded copyWith({
    List<QuestionLanguageData>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<String?>? selectedOption,
    bool? isReview,
    List<String>? questionType,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      isReview: isReview ?? this.isReview,
      questionType: questionType ?? this.questionType,
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
  final List<bool> answeredStatus;

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
  });
}

class ReviewTest extends QuestionState {
  final List<QuestionLanguageData> questions;
  final List<String> selectedOption;
  final List<bool> answeredStatus;

  ReviewTest(this.questions, this.selectedOption, this.answeredStatus);
}
