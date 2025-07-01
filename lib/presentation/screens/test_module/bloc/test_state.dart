sealed class QuestionState {}

class QuestionInitial extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<String> questions;
  final int currentIndex;
  final List<bool> answeredStatus;
  final List<int?> selectedOption;
  final int tickCount;

  QuestionLoaded({
    required this.questions,
    required this.currentIndex,
    required this.answeredStatus,
    required this.selectedOption,
    required this.tickCount,
  });

  QuestionLoaded copyWith({
    List<String>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<int?>? selectedOption,
    int? tickCount,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      tickCount: tickCount ?? this.tickCount,
    );
  }
}
