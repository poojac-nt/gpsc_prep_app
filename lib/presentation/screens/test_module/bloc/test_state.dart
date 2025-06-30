sealed class QuestionState {}

class QuestionInitial extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<Map<String, dynamic>> questions;
  final int currentIndex;
  final List<bool> answeredStatus;

  QuestionLoaded({
    required this.questions,
    required this.currentIndex,
    required this.answeredStatus,
  });

  QuestionLoaded copyWith({
    List<Map<String, dynamic>>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredStatus: answeredStatus ?? this.answeredStatus,
    );
  }
}
