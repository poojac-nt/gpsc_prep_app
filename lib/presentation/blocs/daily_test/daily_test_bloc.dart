import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/test_attempt_state_model.dart';

import 'daily_test_event.dart';
import 'daily_test_state.dart';

class DailyTestBloc extends Bloc<DailyTestEvent, DailyTestState> {
  final TestRepository _testRepository;

  DailyTestBloc(this._testRepository) : super(DailyTestInitial()) {
    on<FetchTests>(_fetchTestsAndResults);
    on<LoadMoreTests>(_loadMoreTests);
  }

  Future<void> _fetchTestsAndResults(
    FetchTests event,
    Emitter<DailyTestState> emit,
  ) async {
    emit(DailyTestFetching());

    final testsResult = await _testRepository.fetchDailyTest(offset: 0, limit: 20);

    await testsResult.fold(
      (failure) async {
        emit(DailyTestFetchFailed(failure));
      },
      (tests) async {
        final Map<int, TestAttemptState> attemptStateMap = {};

        // Parallelize fetching attempt states for all tests
        final attemptStateFutures = tests.map(
          (test) => _testRepository.fetchTestAttemptState(test.id),
        );

        final attemptStates = await Future.wait(attemptStateFutures);

        for (int i = 0; i < tests.length; i++) {
          attemptStates[i].fold((_) {}, (state) {
            attemptStateMap[tests[i].id] = state;
          });
        }

        emit(DailyTestFetched(
          tests,
          attemptStateMap,
          hasReachedMax: tests.length < 20,
          offset: tests.length,
        ));
      },
    );
  }

  Future<void> _loadMoreTests(
    LoadMoreTests event,
    Emitter<DailyTestState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyTestFetched ||
        currentState.hasReachedMax ||
        currentState.isFetchingMore) {
      return;
    }

    emit(currentState.copyWith(isFetchingMore: true));

    final testsResult = await _testRepository.fetchDailyTest(
      offset: currentState.offset,
      limit: 20,
    );

    await testsResult.fold(
      (failure) async {
        emit(currentState.copyWith(isFetchingMore: false));
      },
      (newTests) async {
        if (newTests.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true, isFetchingMore: false));
          return;
        }

        final Map<int, TestAttemptState> attemptStateMap = Map.from(currentState.testResults);

        // Parallelize fetching attempt states for newly fetched tests
        final attemptStateFutures = newTests.map(
          (test) => _testRepository.fetchTestAttemptState(test.id),
        );

        final attemptStates = await Future.wait(attemptStateFutures);

        for (int i = 0; i < newTests.length; i++) {
          attemptStates[i].fold((_) {}, (state) {
            attemptStateMap[newTests[i].id] = state;
          });
        }

        emit(DailyTestFetched(
          currentState.dailyTestModel + newTests,
          attemptStateMap,
          hasReachedMax: newTests.length < 20,
          isFetchingMore: false,
          offset: currentState.offset + newTests.length,
        ));
      },
    );
  }
}
