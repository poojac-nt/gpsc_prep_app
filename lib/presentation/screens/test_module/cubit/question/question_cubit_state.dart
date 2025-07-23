import '../../../../../domain/entities/question_language_model.dart';

sealed class QuestionCubitState {}

final class QuestionCubitInitial extends QuestionCubitState {}

final class QuestionCubitLoaded extends QuestionCubitState {
  final List<QuestionLanguageData> questions;
  final int currentIndex;
  final bool isReview;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;
  final List<bool?>? isCorrect;
  final bool isQuitTest;

  QuestionCubitLoaded({
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
  String? get currentSelected => selectedOption[currentIndex];

  QuestionCubitLoaded copyWith({
    List<QuestionLanguageData>? questions,
    int? currentIndex,
    List<bool>? answeredStatus,
    List<bool?>? isCorrect,
    List<String?>? selectedOption,
    bool? isReview,
    bool? isQuitTest,
  }) {
    return QuestionCubitLoaded(
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
