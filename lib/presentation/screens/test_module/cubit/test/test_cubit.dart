import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/data/repositories/prelims_progress_repository.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';
import 'package:gpsc_prep_app/utils/extensions/question_model_extension.dart';
import 'package:hive/hive.dart';

class TestCubit extends Cubit<TestCubitSubmitted> {
  TestCubit() : super(TestCubitSubmitted.initial());
  final _log = getIt<LogHelper>();
  final cache = getIt<CacheManager>();
  final _repository = getIt<TestRepository>();

  Future<void> calculateAndEmitTestResult({
    required int testId,
    required List<QuestionModel> questionsModel,
    required List<QuestionLanguageData> questions,
    required List<String?> selectedOption,
    required List<bool> answeredStatus,
    required List<int> marks,
    required int minSpent,
    required int secSpent,
    required String languageCode,
  }) async {
    // Clear any existing prelims progress for this test
    final userId = cache.getUserId();
    await getIt<PrelimsProgressRepository>().deleteProgress(userId, testId);

    final attempted = answeredStatus.where((status) => status).length;
    final notAttempted = questionsModel.length - attempted;
    final timeSpent = (minSpent * 60) + secSpent;

    int correctAnswers = 0;
    int incorrectAnswers = 0;
    List<bool?> isCorrect = [];
    double totalScore = 0.0;

    for (int i = 0; i < questionsModel.length; i++) {
      final userAnswer = selectedOption[i];
      final correctAnswer =
          questionsModel[i].getLanguageData(languageCode).correctAnswer;
      final questionId = questionsModel[i].questionId;

      bool? isAnswerCorrect;
      if (userAnswer != null) {
        // Get identifiers for both user answer and correct answer for reliable comparison
        final userId = _getOptionIdentifier(
          userAnswer,
          questionsModel[i].getLanguageData(languageCode),
        );
        final correctId = _getOptionIdentifier(
          correctAnswer,
          questionsModel[i].getLanguageData(languageCode),
        );

        if (userId != null &&
            userId.toUpperCase() == correctId?.toUpperCase()) {
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
        final optionIdentifier = _getOptionIdentifier(
          selectedOption[i],
          questionsModel[i].getLanguageData(languageCode),
        );

        final detailedTestResult = DetailedTestResult(
          userId: cache.getUserId(),
          testId: testId,
          questionId: questionId,
          isCorrect: isAnswerCorrect,
          selectedOption: optionIdentifier,
        );
        final isOnline = getIt<ConnectivityBloc>().state is ConnectivityOnline;
        if (!isOnline) {
          final box = Hive.box<DetailedTestResult>('detailed_test_results');
          box.add(detailedTestResult);
          _log.e(
            "❌ No internet connection, skipping insert for question $questionId",
          );
        } else {
          final result = await _repository.insertTestResultDetail(
            detailedTestResult: detailedTestResult,
          );

          result.fold(
            (failure) => _log.e(
              'Insert failed for question $questionId: ${failure.message}',
            ),
            (_) => _log.i('Insert successful for question $questionId'),
          );
        }
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
