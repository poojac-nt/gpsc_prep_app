part of 'question_bloc.dart';

@immutable
sealed class QuestionState {}

final class QuestionInitial extends QuestionState {}

final class QuestionLoading extends QuestionState {}

final class QuestionLoaded extends QuestionState {
  final List<QuestionLanguageData> questions;

  QuestionLoaded({required this.questions});

  QuestionLoaded copyWith({List<QuestionLanguageData>? questions}) {
    return QuestionLoaded(questions: questions ?? this.questions);
  }
}

class QuestionLoadFailed extends QuestionState {
  final Failure failure;

  QuestionLoadFailed(this.failure);
}
