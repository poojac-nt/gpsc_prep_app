part of 'question_bloc.dart';

@immutable
sealed class QuestionState {}

final class QuestionInitial extends QuestionState {}

final class QuestionLoading extends QuestionState {}

final class QuestionLoaded extends QuestionState {
  final List<QuestionLanguageData> questions;
  final int currentIndex;
  final List<bool> answeredStatus;
  final List<String?> selectedOption;
  final List<bool?>? isCorrect;
  final bool isReview;

  QuestionLoaded({
    required this.questions,
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
    // List<bool?>? isCorrect,
    bool? isReview,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      // isCorrect: isCorrect ?? this.isCorrect,
      isReview: isReview ?? this.isReview,
    );
  }
}

class QuestionLoadFailed extends QuestionState {
  final Failure failure;

  QuestionLoadFailed(this.failure);
}
