import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';
import 'package:gpsc_prep_app/utils/extensions/question_model_extension.dart';

class TestCubit extends Cubit<TestCubitSubmitted> {
  TestCubit() : super(TestCubitSubmitted.initial());
  final _log = getIt<LogHelper>();
  final cache = getIt<CacheManager>();
  final _repository = getIt<TestRepository>();

  Future<void> calculateAndEmitTestResult({
    // ✅ FIXED
    required int testId,
    required List<QuestionModel> questions,
    required List<String?> selectedOption,
    required List<bool> answeredStatus,
    required List<int> marks,
    required int minSpent,
    required int secSpent,
    required String languageCode,
  }) async {
    final attempted = answeredStatus.where((status) => status).length;
    final notAttempted = questions.length - attempted;
    final timeSpent = (minSpent * 60) + secSpent;

    int correctAnswers = 0;
    int incorrectAnswers = 0;
    List<bool?> isCorrect = [];
    double totalScore = 0.0;

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = selectedOption[i];
      final correctAnswer =
          questions[i].getLanguageData(languageCode).correctAnswer;
      final questionId = questions[i].questionId;

      bool? isAnswerCorrect;
      if (userAnswer != null) {
        if (userAnswer.trim() == correctAnswer.trim()) {
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
        final isOnline = getIt<ConnectivityBloc>().state is ConnectivityOnline;
        if (isOnline) {
          _log.e(
            "❌ No internet connection, skipping insert for question $questionId",
          );
          continue; // ✅ FIXED
        }

        final result = await _repository.insertTestResultDetail(
          userId: cache.getUserId(),
          testId: testId,
          questionId: questionId,
          isCorrect: isAnswerCorrect,
        );

        result.fold(
          (failure) => _log.e(
            'Insert failed for question $questionId: ${failure.message}',
          ),
          (_) => _log.i('Insert successful for question $questionId'),
        );
      }
    }

    emit(
      TestCubitSubmitted(
        questions: questions,
        selectedOption: selectedOption,
        answeredStatus: answeredStatus,
        isAnswerCorrect: isCorrect,
        totalQuestions: questions.length,
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
}
