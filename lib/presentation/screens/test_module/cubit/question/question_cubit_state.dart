import 'package:gpsc_prep_app/domain/entities/desc_question_language_model.dart';

import '../../../../../domain/entities/question_language_model.dart';

sealed class QuestionCubitState {}

final class QuestionCubitInitial extends QuestionCubitState {}

final class McqQuestionCubitLoaded extends QuestionCubitState {
  final List<QuestionLanguageData> questions;
  final int currentIndex;
  final bool isReview;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;
  final List<bool?>? isCorrect;
  final bool isQuitTest;

  McqQuestionCubitLoaded({
    required this.questions,
    required this.currentIndex,
    this.isReview = false,
    required this.answeredStatus,
    required this.selectedOption,
    this.isCorrect,
    this.isQuitTest = false,
  });

  double get progress =>
      questions.length <= 1 ? 1.0 : (currentIndex + 1) / questions.length;

  int get answered => answeredStatus.where((value) => value).toList().length;

  List<String> get options => questions[currentIndex].getOptions();

  McqQuestionCubitLoaded copyWith({
    List<QuestionLanguageData>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<bool?>? isCorrect,
    List<String?>? selectedOption,
    bool? isReview,
    bool? isQuitTest,
  }) {
    return McqQuestionCubitLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isReview: isReview ?? this.isReview,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      isCorrect: isCorrect ?? this.isCorrect,
      isQuitTest: isQuitTest ?? this.isQuitTest,
    );
  }
}

final class DescQuestionCubitLoaded extends QuestionCubitState {
  final List<DescQuestionLanguageData> questions;
  final int currentIndex;
  final bool isReview;
  final bool isQuitTest;

  DescQuestionCubitLoaded({
    required this.questions,
    required this.currentIndex,
    this.isReview = false,
    this.isQuitTest = false,
  });

  double get progress =>
      questions.length <= 1 ? 1.0 : (currentIndex + 1) / questions.length;

  DescQuestionCubitLoaded copyWith({
    List<DescQuestionLanguageData>? questions,
    int? currentIndex,
    bool? isReview,
    bool? isQuitTest,
  }) {
    return DescQuestionCubitLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isReview: isReview ?? this.isReview,
      isQuitTest: isQuitTest ?? this.isQuitTest,
    );
  }
}
