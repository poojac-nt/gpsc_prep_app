import '../../../../domain/entities/question_model.dart';

sealed class QuestionState {}

class QuestionInitial extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<Question> questions;
  final int currentIndex;
  final List<bool> answeredStatus;
  final List<String?> selectedOption;
  final bool isReview;

  QuestionLoaded({
    required this.questions,
    required this.currentIndex,
    required this.answeredStatus,
    required this.selectedOption,
    this.isReview = false,
  });

  QuestionLoaded copyWith({
    List<Question>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<String?>? selectedOption,

    bool? isReview,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      isReview: isReview ?? this.isReview,
    );
  }
}

class TestSubmitted extends QuestionState {
  final int totalQuestions;
  final int attempted;
  final int notAttempted;
  final int correct;
  final int inCorrect;
  final bool isReview;
  final List<Question> questions;
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
  final List<Question> questions;
  final List<String> selectedOption;
  final List<bool> answeredStatus;

  ReviewTest(this.questions, this.selectedOption, this.answeredStatus);
}
