import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/test_attempt_state_model.dart';

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
        final Map<int, TestAttemptState> attemptStateMap = {};

        for (final test in tests) {
          final attemptStateResult = await _testRepository
              .fetchTestAttemptState(test.id);

          attemptStateResult.fold((_) {}, (state) {
            attemptStateMap[test.id] = state;
          });
        }

        emit(DailyTestFetched(tests, attemptStateMap));
      },
    );
  }
}
