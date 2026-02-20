import 'package:gpsc_prep_app/domain/entities/desc_question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';

import '../../../../../domain/entities/question_language_model.dart';

sealed class QuestionCubitState {}

final class QuestionCubitInitial extends QuestionCubitState {}

final class McqQuestionCubitLoaded extends QuestionCubitState {
  final List<QuestionLanguageData> questions;
  final List<QuestionModel> questionModel;
  final int currentIndex;
  final bool isReview;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;
  final List<bool?>? isCorrect;
  final bool isQuitTest;
  final String currentLanguage;
  final List<int> timePerQuestion;
  final int? currentQuestionStartTime;

  McqQuestionCubitLoaded({
    required this.questionModel,
    required this.questions,
    required this.currentIndex,
    this.isReview = false,
    required this.answeredStatus,
    required this.selectedOption,
    required this.timePerQuestion,
    this.currentQuestionStartTime,
    this.isCorrect,
    this.isQuitTest = false,
    required this.currentLanguage,
  });

  double get progress =>
      questions.length <= 1 ? 1.0 : (currentIndex + 1) / questions.length;

  int get answered => answeredStatus.where((value) => value).toList().length;

  List<String> get options => questions[currentIndex].getOptions();

  McqQuestionCubitLoaded copyWith({
    List<QuestionLanguageData>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<String?>? selectedOption,
    List<bool?>? isCorrect,
    List<int>? timePerQuestion,
    int? currentQuestionStartTime,
    String? currentLanguage,
    bool? isReview,
    bool? isQuitTest,
  }) {
    return McqQuestionCubitLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isReview: isReview ?? this.isReview,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      currentQuestionStartTime:
          currentQuestionStartTime ?? this.currentQuestionStartTime,
      isCorrect: isCorrect ?? this.isCorrect,
      isQuitTest: isQuitTest ?? this.isQuitTest,
      questionModel: questionModel,
      currentLanguage: currentLanguage ?? this.currentLanguage,
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
