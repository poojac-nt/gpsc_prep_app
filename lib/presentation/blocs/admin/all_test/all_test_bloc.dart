import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/domain/entities/all_tests_model.dart';
import 'package:meta/meta.dart';

import '../../../../data/repositories/test_repository.dart';

part 'all_test_event.dart';
part 'all_test_state.dart';

class AllTestBloc extends Bloc<AllTestEvent, AllTestState> {
  final TestRepository _testRepository;

  AllTestBloc(this._testRepository) : super(AllTestInitial()) {
    on<FetchAllTests>(_onFetchAllTests);
  }

  Future<void> _onFetchAllTests(
    FetchAllTests event,
    Emitter<AllTestState> emit,
  ) async {
    emit(AllTestLoading());
    final result = await _testRepository.fetchAllTests();
    result.fold(
      (failure) => emit(AllTestError(failure.message)),
      (allTests) => emit(AllTestLoaded(allTests)),
    );
  }
}
