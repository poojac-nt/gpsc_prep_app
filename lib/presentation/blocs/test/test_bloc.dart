import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';
import 'package:hive/hive.dart';
import '../analytics/analytics_bloc.dart';
import '../detailed_analytics/detailed_analytics_bloc.dart';

part 'test_event.dart';
part 'test_state.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  final TestRepository _testRepository;
  final LogHelper _log = getIt<LogHelper>();

  TestBloc(this._testRepository) : super(TestResultInitial()) {
    on<SubmitTest>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitTest event, Emitter<TestState> emit) async {
    final testResult = TestResultModel(
      userId: getIt<CacheManager>().user!.id!,
      testId: event.testId,
      totalQuestions: event.totalQuestions ?? 0,
      correctAnswers: event.correctAnswers ?? 0,
      inCorrectAnswers: event.inCorrectAnswers ?? 0,
      attemptedQuestions: event.attemptedQuestions ?? 0,
      notAttemptedQuestions: event.notAttemptedQuestions ?? 0,
      score: event.score ?? 0,
      timeTaken: event.timeTaken ?? 0,
    );

    final isOnline = getIt<ConnectivityBloc>().state is ConnectivityOnline;
    if (!isOnline) {
      final box = Hive.box<TestResultModel>('test_results');
      box.put('latest', testResult);

      if (event.batchResults.isNotEmpty) {
        final detailedBox = Hive.box<DetailedTestResult>(
          'detailed_test_results',
        );
        await detailedBox.addAll(event.batchResults);
        _log.e(
          "❌ Offline: saved ${event.batchResults.length} detailed results to Hive",
        );
      }

      _log.e("❌ No internet connection");
      emit(
        TestSubmitted(
          questions: event.questions,
          selectedOption: event.selectedOptions,
          answeredStatus: event.answeredStatus,
        ),
      );
      return;
    }

    try {
      final result = await _testRepository.submitTestResultWithDetails(
        testResult,
        event.batchResults,
      );
      _log.i("✅ Internet is available. Proceeding with RPC...");

      TestResultWithTopScoreModel? serverResult;

      result.fold(
        (failure) => _log.e("🚨 RPC submission failed: ${failure.message}"),
        (data) {
          _log.i("✅ Test result and details submitted via RPC.");
          serverResult = data;
          // Clear analytics cache so next time it's opened it fetches fresh data
          getIt<AnalyticsBloc>().add(ResetAnalyticsEvent());
          getIt<DetailedAnalyticsBloc>().add(ResetDetailedAnalyticsEvent());
        },
      );

      emit(
        TestSubmitted(
          questions: event.questions,
          selectedOption: event.selectedOptions,
          answeredStatus: event.answeredStatus,
          serverResult: serverResult,
        ),
      );
    } catch (e) {
      _log.e("🚨 Submission failed: $e");
      emit(
        TestSubmissionFailed(Failure("Submission failed due to an error: $e")),
      );
    }
  }
}
