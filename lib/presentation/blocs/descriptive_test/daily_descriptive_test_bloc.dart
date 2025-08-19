import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';

import 'daily_descriptive_test_event.dart';
import 'daily_descriptive_test_state.dart';

class DailyDescTestBloc extends Bloc<DailyDescTestEvent, DailyDescTestState> {
  final TestRepository _testRepository;
  DailyDescTestBloc(this._testRepository) : super(DailyTestInitial()) {
    on<FetchAllTests>(_fetchAllTests);
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
        emit(DailyDescTestFetched(tests));
      },
    );
  }
}
