part of 'question_bloc.dart';

@immutable
sealed class QuestionEvent {}

class LoadQuestion extends QuestionEvent {
  final int testId;
  final String? language;

  LoadQuestion(this.testId, this.language);
}
