part of 'question_bloc.dart';

@immutable
sealed class QuestionState {}

final class QuestionInitial extends QuestionState {}

final class QuestionLoading extends QuestionState {}

final class McqQuestionLoaded extends QuestionState {
  final List<QuestionModel> questionsModels;
  final List<QuestionLanguageData> questions;
  final List<int> marks;
  final List<String> subjects;
  final List<String> topics;
  final List<DifficultyLevel> difficultyLevel;

  McqQuestionLoaded({
    required this.questionsModels,
    required this.questions,
    required this.marks,
    required this.subjects,
    required this.topics,
    required this.difficultyLevel,
  });
}

final class DescQuestionLoaded extends QuestionState {
  final List<DescQuestionModel> questionsModels;
  final List<DescQuestionLanguageData> questions;
  final List<int> marks;
  final List<String> subjects;
  final List<String> topics;
  final List<DifficultyLevel> difficultyLevel;

  DescQuestionLoaded({
    required this.questionsModels,
    required this.questions,
    required this.marks,
    required this.subjects,
    required this.topics,
    required this.difficultyLevel,
  });
}

class QuestionLoadFailed extends QuestionState {
  final Failure failure;

  QuestionLoadFailed(this.failure);
}
