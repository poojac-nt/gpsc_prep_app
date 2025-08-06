part of 'question_bloc.dart';

@immutable
sealed class QuestionEvent {}

/// Event to fetch raw questions data (e.g., from API)
final class FetchQuestions extends QuestionEvent {
  final int testId;

  FetchQuestions(this.testId);
}

/// Event to process the fetched data and prepare for display
final class PrepareQuestions extends QuestionEvent {
  final List<QuestionModel> questionsModels;

  PrepareQuestions({required this.questionsModels});
}
