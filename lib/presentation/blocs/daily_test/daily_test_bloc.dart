import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';

import 'daily_test_event.dart';
import 'daily_test_state.dart';

class DailyTestBloc extends Bloc<DailyTestEvent, DailyTestState> {
  final TestRepository _testRepository;

  DailyTestBloc(this._testRepository) : super(DailyTestInitial()) {
    on<FetchTests>(_fetchTestsAndResults);
  }

  Future<void> _fetchTestsAndResults(
    FetchTests event,
    Emitter<DailyTestState> emit,
  ) async {
    emit(DailyTestFetching());

    final testsResult = await _testRepository.fetchDailyTest();
    final resultsResult = await _testRepository.fetchAllTestResults();

    await testsResult.fold(
      (failure) async {
        emit(DailyTestFetchFailed(failure));
      },
      (tests) async {
        final Map<int, TestResultModel> resultMap = {};

        resultsResult.fold((_) {}, (results) {
          for (final result in results) {
            resultMap[result.testId] = result;
          }
        });

        emit(DailyTestFetched(tests, resultMap));
      },
    );
  }
}
