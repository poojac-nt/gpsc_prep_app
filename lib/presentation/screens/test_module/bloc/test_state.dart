import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/utils/extensions/question_markdown.dart';

import '../../../../domain/entities/question_language_model.dart';

sealed class QuestionState {}

class QuestionInitial extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<QuestionLanguageData> questions;
  final int currentIndex;
  final List<bool> answeredStatus;
  final List<String?> selectedOption;
  final bool isReview;

  QuestionLoaded({
    required this.questions,
    required this.currentIndex,
    required this.answeredStatus,
    required this.selectedOption,
    this.isReview = false,
  });

  double get progress => currentIndex / (questions.length - 1);
  int get answered => answeredStatus.where((value) => value).toList().length;
  List<String> get options => questions[currentIndex].getOptions();
  String? get currentSelected => selectedOption[currentIndex];
  // Widget get question => questions[currentIndex].toQuestionWidget();

  QuestionLoaded copyWith({
    List<QuestionLanguageData>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<String?>? selectedOption,
    bool? isReview,
  }) {
    return QuestionLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
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
  final bool isReview;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;

  TestSubmitted({
    required this.totalQuestions,
    required this.attempted,
    required this.notAttempted,
    required this.correct,
    required this.inCorrect,
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
    required this.isReview,
  });
}

class ReviewTest extends QuestionState {
  final List<QuestionLanguageData> questions;
  final List<String> selectedOption;
  final List<bool> answeredStatus;

  ReviewTest(this.questions, this.selectedOption, this.answeredStatus);
}
