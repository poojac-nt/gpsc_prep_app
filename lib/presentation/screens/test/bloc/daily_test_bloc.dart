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
        final languageAvailability = <int, Set<String>>{};

        final getLanguages = GetAvailableLanguagesForTestUseCase(
          _testRepository,
        );

        for (final test in tests) {
          final availableLanguages = await getLanguages(test.id);
          languageAvailability[test.id] = availableLanguages;

          final result = await _testRepository.singleTestResult(test.id);

          result.fold((_) {}, (testResult) {
            if (testResult != null) {
              resultMap[test.id] = testResult;
            }
          });
        }

        emit(DailyTestFetched(tests, resultMap, languageAvailability));
      },
    );
  }
}
