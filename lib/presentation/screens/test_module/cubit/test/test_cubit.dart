import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/data/repositories/prelims_progress_repository.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';
import 'package:gpsc_prep_app/utils/extensions/question_model_extension.dart';

class TestCubit extends Cubit<TestCubitSubmitted> {
  TestCubit() : super(TestCubitSubmitted.initial());
  final cache = getIt<CacheManager>();

  Future<void> calculateAndEmitTestResult({
    required int testId,
    required List<QuestionModel> questionsModel,
    required List<QuestionLanguageData> questions,
    required List<String?> selectedOption,
    required List<bool> answeredStatus,
    required List<int> timePerQuestion,
    required List<int> marks,
    required int minSpent,
    required int secSpent,
    required String languageCode,
  }) async {
    final userId = cache.getUserId();

    await getIt<PrelimsProgressRepository>().deleteProgress(userId, testId);

    final attempted = answeredStatus.where((e) => e).length;
    final notAttempted = questionsModel.length - attempted;
    final timeSpent = (minSpent * 60) + secSpent;

    int correctAnswers = 0;
    int incorrectAnswers = 0;
    double totalScore = 0.0;

    final List<bool?> isCorrect = [];
    final List<DetailedTestResult> batchResults = [];

    for (int i = 0; i < questionsModel.length; i++) {
      final userAnswer = selectedOption[i];
      final languageData = questionsModel[i].getLanguageData(languageCode);
      final correctAnswer = languageData.correctAnswer;
      final questionId = questionsModel[i].questionId;
      final timeSpentOnQuestion =
          timePerQuestion.length > i ? timePerQuestion[i] : 0;

      bool? isAnswerCorrect;
      if (userAnswer != null) {
        final userOptionId = _getOptionIdentifier(userAnswer, languageData);
        final correctOptionId = _getOptionIdentifier(
          correctAnswer,
          languageData,
        );

        if (userOptionId != null &&
            userOptionId.toUpperCase() == correctOptionId?.toUpperCase()) {
          correctAnswers++;
          totalScore += marks[i];
          isAnswerCorrect = true;
        } else {
          incorrectAnswers++;
          totalScore -= 0.33 * marks[i];
          isAnswerCorrect = false;
        }
      } else {
        isAnswerCorrect = null;
      }

      isCorrect.add(isAnswerCorrect);

      if (isAnswerCorrect != null) {
        final optionIdentifier = _getOptionIdentifier(userAnswer, languageData);

        batchResults.add(
          DetailedTestResult(
            userId: userId,
            testId: testId,
            questionId: questionId,
            isCorrect: isAnswerCorrect,
            attemptNo: 1,
            selectedOption: optionIdentifier,
            timeSpent: timeSpentOnQuestion,
          ),
        );
      }
    }

    emit(
      TestCubitSubmitted(
        questionsModel: questionsModel,
        questions: questions,
        selectedOption: selectedOption,
        answeredStatus: answeredStatus,
        isAnswerCorrect: isCorrect,
        totalQuestions: questionsModel.length,
        attemptedQuestions: attempted,
        notAttemptedQuestions: notAttempted,
        correctAnswers: correctAnswers,
        inCorrectAnswers: incorrectAnswers,
        isReview: false,
        score: totalScore,
        timeSpent: timeSpent,
        batchResults: batchResults,
        timePerQuestion: timePerQuestion,
      ),
    );
  }

  /// Helper method to get option identifier (A, B, C, D) from selected option text
  String? _getOptionIdentifier(
    String? selectedOptionText,
    QuestionLanguageData questionData,
  ) {
    if (selectedOptionText == null) return null;

    final trimmedSelection = selectedOptionText.trim();

    // If it's already a single letter identifier, return it as is
    if (trimmedSelection.length == 1) {
      final char = trimmedSelection.toUpperCase();
      if (char == 'A' || char == 'B' || char == 'C' || char == 'D') {
        return trimmedSelection;
      }
    }

    // Otherwise, match against the option text
    final trimmedA = questionData.optA.trim();
    final trimmedB = questionData.optB.trim();
    final trimmedC = questionData.optC.trim();
    final trimmedD = questionData.optD.trim();

    if (trimmedSelection == trimmedA) {
      return _resolveCase(trimmedA, 'A', 'a');
    }
    if (trimmedSelection == trimmedB) {
      return _resolveCase(trimmedB, 'B', 'b');
    }
    if (trimmedSelection == trimmedC) {
      return _resolveCase(trimmedC, 'C', 'c');
    }
    if (trimmedSelection == trimmedD) {
      return _resolveCase(trimmedD, 'D', 'd');
    }

    return null;
  }

  String _resolveCase(String optionText, String upper, String lower) {
    final trimmed = optionText.trim();
    if (trimmed.isEmpty) return upper;
    // Check if the original text started with a lowercase letter
    return trimmed[0] == trimmed[0].toLowerCase() ? lower : upper;
  }
}
