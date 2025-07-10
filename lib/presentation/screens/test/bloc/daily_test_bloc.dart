import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/presentation/screens/test/bloc/daily_test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test/bloc/daily_test_state.dart';

import 'daily_test_event.dart';

class DailyTestBloc extends Bloc<DailyTestEvent, DailyTestState> {
  TestRepository _testRepository;
  DailyTestBloc(this._testRepository) : super(DailyTestInitial()) {
    on<DailyTestInit>(_dailyTestInit);
    on<FetchDailyTest>(_fetchDailyTest);
  }
  Future<void> _dailyTestInit(
    DailyTestInit event,
    Emitter<DailyTestState> emit,
  ) async {
    emit(DailyTestInitial());
  }

  Future<void> _fetchDailyTest(
    FetchDailyTest event,
    Emitter<DailyTestState> emit,
  ) async {
    emit(DailyTestFetching());
    final result = await _testRepository.fetchDailyTest();
    result.fold(
      (failure) {
        emit(DailyTestFetchFailed(failure));
      },
      (dailyTestModels) {
        emit(DailyTestFetched(dailyTestModels));
      },
    );
  }
}
