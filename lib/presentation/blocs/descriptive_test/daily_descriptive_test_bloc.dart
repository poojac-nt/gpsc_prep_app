import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';

import 'daily_descriptive_test_event.dart';
import 'daily_descriptive_test_state.dart';

class DailyDescTestBloc extends Bloc<DailyDescTestEvent, DailyDescTestState> {
  final TestRepository _testRepository;

  DailyDescTestBloc(this._testRepository) : super(DailyTestInitial()) {
    on<FetchAllTests>(_fetchAllTests);
    on<SubmitDescTest>(_submitDescTest);
  }

  Future<void> _fetchAllTests(
    DailyDescTestEvent event,
    Emitter<DailyDescTestState> emit,
  ) async {
    emit(DailyDescTestFetching());
    final testsResult = await _testRepository.fetchDailyDescTest();
    testsResult.fold(
      (failure) {
        emit(DailyDescTestFetchFailed(failure));
      },
      (tests) {
        if (tests.isEmpty) {
          emit(
            DailyDescTestFetchFailed(
              Failure('No tests available at the moment'),
            ),
          );
          return;
        }
        emit(DailyDescTestFetched(tests));
      },
    );
  }

  Future<void> _submitDescTest(
    SubmitDescTest event,
    Emitter<DailyDescTestState> emit,
  ) async {
    emit(DescTestSubmit());
    final submitResult = await _testRepository.submitDescriptiveTest(
      event.testId,
      event.answers,
    );
    submitResult.fold(
      (failure) {
        emit(DescTestSubmitFailed(failure));
      },
      (message) {
        emit(DescTestSubmitSuccess("Test submitted successfully!"));
      },
    );
  }
}
