import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_state.dart';
import 'package:hive/hive.dart';

import '../../cubit/test/test_cubit.dart';
import '../../cubit/test/test_cubit_state.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  final TestRepository _testRepository;
  final LogHelper _log = getIt<LogHelper>();

  TestBloc(this._testRepository) : super(TestResultInitial()) {
    on<SubmitTest>(_onSubmit);
    on<FetchSingleTestResultEvent>(_onFetchSingleResult);
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
    if (isOnline) {
      _testRepository.insertTestResult(testResult);
      _log.i("✅ Internet is available. Proceeding...");
    } else {
      final box = Hive.box<TestResultModel>('test_results');
      box.put('latest', testResult);
      _log.e("❌ No internet connection");
      return;
    }
    emit(
      TestSubmitted(
        questions: event.questions,
        selectedOption: event.selectedOptions,
        answeredStatus: event.answeredStatus,
      ),
    );
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
