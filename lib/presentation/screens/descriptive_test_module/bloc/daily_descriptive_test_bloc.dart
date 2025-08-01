import 'package:bloc/bloc.dart';

import '../../../../data/repositories/desc_test_repository.dart';
import 'daily_descriptive_test_event.dart';
import 'daily_descriptive_test_state.dart';

class DailyDescTestBloc extends Bloc<DailyDescTestEvent, DailyDescTestState> {
  final DescTestRepository _descTestRepository;
  DailyDescTestBloc(this._descTestRepository) : super(DailyTestInitial()) {
    on<FetchAllTests>(_fetchAllTests);
  }
  Future<void> _fetchAllTests(
    DailyDescTestEvent event,
    Emitter<DailyDescTestState> emit,
  ) async {
    emit(DailyDescTestFetching());
    final testsResult = await _descTestRepository.fetchDailyDescTest();
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
