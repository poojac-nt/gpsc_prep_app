import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:meta/meta.dart';

part 'daily_test_event.dart';
part 'daily_test_state.dart';

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

    final testsResult =
        await _testRepository.fetchDailyTest(); // fetch all tests

    await testsResult.fold(
      (failure) async {
        emit(DailyTestFetchFailed(failure));
      },
      (tests) async {
        final resultMap = <int, TestResultModel>{};

        for (final test in tests) {
          final result = await _testRepository.singleTestResult(test.id);

          result.fold(
            (_) {}, // silently ignore failure for individual test result
            (testResult) {
              if (testResult != null) {
                resultMap[test.id] = testResult;
              }
            },
          );
        }

        emit(DailyTestFetched(tests, resultMap));
      },
    );
  }
}
