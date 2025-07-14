import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/Use%20Case/network_check.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_state.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../cubit/test/test_cubit.dart';
import '../../cubit/test/test_cubit_state.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  final TestRepository _testRepository;
  final CacheManager _cacheManager = getIt<CacheManager>();
  final LogHelper _log = getIt<LogHelper>();

  TestBloc(this._testRepository) : super(TestResultInitial()) {
    on<SubmitTest>(_onSubmit);
    on<FetchSingleTestResultEvent>(_onFetchSingleResult);
  }

  Future<void> _onSubmit(SubmitTest event, Emitter<TestState> emit) async {
    var cubit = getIt<TestCubit>();
    cubit.calculateAndEmitTestResult(
      questions: event.questions,
      selectedOption: event.selectedOptions,
      answeredStatus: event.answeredStatus,
    );

    if (cubit.state is TestCubitSubmitted) {
      var currentCubitState = cubit.state as TestCubitSubmitted;
      emit(
        TestSubmitted(
          questions: event.questions,
          selectedOption: event.selectedOptions,
          answeredStatus: event.answeredStatus,
        ),
      );

      final networkChecker = NetworkCheckUseCase(
        connectivity: Connectivity(),
        httpClient: http.Client(),
      );
      final online = await networkChecker.isOnline();
      if (online) {
        _testRepository.insertTestResult(
          TestResultModel(
            userId: getIt<CacheManager>().user!.id!,
            testId: event.testId,
            totalQuestions: currentCubitState.totalQuestions ?? 0,
            correctAnswers: currentCubitState.correct ?? 0,
            inCorrectAnswers: currentCubitState.inCorrect ?? 0,
            attemptedQuestions: currentCubitState.attempted ?? 0,
            notAttemptedQuestions: currentCubitState.notAttempted ?? 0,
            score: currentCubitState.score ?? 0,
            timeTaken: currentCubitState.timeSpent ?? 0,
          ),
        );
        _log.i("✅ Internet is available. Proceeding...");
        // Proceed with API or Supabase request
      } else {
        final box = Hive.box<TestResultModel>('test_results');
        box.put(
          'latest',
          TestResultModel(
            userId: getIt<CacheManager>().user!.id!,
            testId: event.testId,
            totalQuestions: currentCubitState.totalQuestions ?? 0,
            correctAnswers: currentCubitState.correct ?? 0,
            inCorrectAnswers: currentCubitState.inCorrect ?? 0,
            attemptedQuestions: currentCubitState.attempted ?? 0,
            notAttemptedQuestions: currentCubitState.notAttempted ?? 0,
            score: currentCubitState.score ?? 0,
            timeTaken: currentCubitState.timeSpent ?? 0,
          ),
        );
        _log.e("❌ No internet connection");
        return;
      }
    }
  }

  Future<void> _onFetchSingleResult(
    FetchSingleTestResultEvent event,
    Emitter<TestState> emit,
  ) async {
    emit(SingleResultLoading());

    final result = await _testRepository.singleTestResult(event.testId);

    result.fold(
      (failure) => emit(SingleResultFailure(failure)),
      (data) => emit(SingleResultSuccess(data!)),
    );
  }
}

double calculatePercentage({
  required int totalQuestions,
  required int correctAnswers,
  required int wrongAnswers,
}) {
  const double marksPerCorrect = 2.0;
  const double negativeMarkFraction = 0.33;

  // Calculate not attempted
  int notAttempted = totalQuestions - correctAnswers - wrongAnswers;

  // Ensure values are logical
  if (notAttempted < 0) {
    throw ArgumentError(
      'Total of correct and wrong answers cannot exceed total questions',
    );
  }

  // Score formula
  double score =
      (correctAnswers * marksPerCorrect) -
      (wrongAnswers * marksPerCorrect * negativeMarkFraction);

  double maxScore = totalQuestions * marksPerCorrect;

  // Avoid division by zero
  if (maxScore == 0) return 0.0;

  // Percentage score
  double percentage = (score / maxScore) * 100;

  return percentage.clamp(0.0, 100.0);
}
