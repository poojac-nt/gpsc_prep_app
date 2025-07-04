import '../../../../domain/entities/question_model.dart';

sealed class QuestionState {}

class QuestionInitial extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<Question> questions;
  final int currentIndex;
  final List<bool> answeredStatus;
  final List<String?> selectedOption;
  final int tickCount;
  final bool isReview;

  QuestionLoaded({
    required this.questions,
    required this.currentIndex,
    required this.answeredStatus,
    required this.selectedOption,
    required this.tickCount,
    this.isReview = false,
  });

  QuestionLoaded copyWith({
    List<Question>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<String?>? selectedOption,
    int? tickCount,
    bool? isReview,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      tickCount: tickCount ?? this.tickCount,
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
  final int timeSpent;
  final List<Question> questions;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;

  TestSubmitted({
    required this.totalQuestions,
    required this.attempted,
    required this.notAttempted,
    required this.correct,
    required this.inCorrect,
    required this.timeSpent,
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
  });
}

class ReviewTest extends QuestionState {
  final List<Question> questions;
  final List<String> selectedOption;
  final List<bool> answeredStatus;

  ReviewTest(this.questions, this.selectedOption, this.answeredStatus);
}
