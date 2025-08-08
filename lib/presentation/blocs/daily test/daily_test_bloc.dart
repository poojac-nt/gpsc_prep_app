import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/usecases/get_available_language_usecase.dart';

import 'daily_test_event.dart';
import 'daily_test_state.dart';

class DailyTestBloc extends Bloc<DailyTestEvent, DailyTestState> {
  final TestRepository _testRepository;

  DailyTestBloc(this._testRepository) : super(DailyTestInitial()) {
    on<FetchTests>(_fetchTestsAndResults);
    on<FetchSingleTestFromId>(_fetchSingleTestFromId);
  }

  Future<void> _fetchTestsAndResults(
    FetchTests event,
    Emitter<DailyTestState> emit,
  ) async {
    emit(DailyTestFetching());

    final testsResult = await _testRepository.fetchDailyTest();

    await testsResult.fold(
      (failure) async {
        emit(DailyTestFetchFailed(failure));
      },
      (tests) async {
        final resultMap = <int, TestResultModel>{};

        for (final test in tests) {
          final result = await _testRepository.singleTestResult(test.id);

          result.fold((_) {}, (testResult) {
            if (testResult != null) {
              resultMap[test.id] = testResult;
            }
          });
        }
        emit(DailyTestFetched(tests, resultMap));
      },
    );
  }

  Future<void> _fetchSingleTestFromId(
    FetchSingleTestFromId event,
    Emitter<DailyTestState> emit,
  ) async {
    emit(SingleTestFetching());
    final testResult = await _testRepository.fetchSingleTestFromId(
      event.testId,
    );
    await testResult.fold(
      (failure) {
        emit(SingleTestFetchingFailed(failure));
      },
      (test) async {
        final languageAvailability = <int, Set<String>>{};

        final getLanguages = GetAvailableLanguagesForTestUseCase(
          _testRepository,
        );
        final availableLanguages = await getLanguages(test.id);
        languageAvailability[test.id] = availableLanguages;
        emit(SingleTestFetched(test, languageAvailability));
      },
    );
  }
}
