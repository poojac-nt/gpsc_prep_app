import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/utils/extensions/question_model_extension.dart';

sealed class QuestionCubitState {}

final class QuestionCubitInitial extends QuestionCubitState {}

final class QuestionCubitLoaded extends QuestionCubitState {
  final List<QuestionModel> questions;
  final String languageCode;
  final int currentIndex;
  final bool isReview;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;
  final List<bool?>? isCorrect;
  final bool isQuitTest;

  QuestionCubitLoaded({
    required this.questions,
    required this.currentIndex,
    required this.languageCode,
    this.isReview = false,
    required this.answeredStatus,
    required this.selectedOption,
    this.isCorrect,
    this.isQuitTest = false,
  });

  // Progress and convenience
  double get progress =>
      questions.length <= 1 ? 1.0 : (currentIndex + 1) / questions.length;

  int get answered => answeredStatus.where((value) => value).length;

  QuestionModel get currentQuestion => questions[currentIndex];

  QuestionLanguageData get currentLanguageData =>
      questions[currentIndex].getLanguageData(languageCode);

  List<String> get options => currentLanguageData.getOptions();

  QuestionCubitLoaded copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    String? languageCode,
    List<bool>? answeredStatus,
    List<bool?>? isCorrect,
    List<String?>? selectedOption,
    bool? isReview,
    bool? isQuitTest,
  }) {
    return QuestionCubitLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      languageCode: languageCode ?? this.languageCode,
      isReview: isReview ?? this.isReview,
      answeredStatus: answeredStatus ?? this.answeredStatus,
      selectedOption: selectedOption ?? this.selectedOption,
      isCorrect: isCorrect ?? this.isCorrect,
      isQuitTest: isQuitTest ?? this.isQuitTest,
    );
  }
}
