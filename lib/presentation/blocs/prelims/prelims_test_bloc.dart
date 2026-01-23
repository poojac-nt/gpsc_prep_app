import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/presentation/blocs/prelims/prelims_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/prelims/prelims_test_state.dart';

import '../../../domain/entities/result_model.dart';

class PrelimsTestBloc extends Bloc<PrelimsTestEvent, PrelimsTestState> {
  final TestRepository _testRepository;

  PrelimsTestBloc(this._testRepository) : super(PrelimsTestFetching()) {
    on<FetchPrelimsTest>(_fetchPrelimsTests);
  }
  Future<void> _fetchPrelimsTests(
    FetchPrelimsTest event,
    Emitter<PrelimsTestState> emit,
  ) async {
    emit(PrelimsTestFetching());
    final prelimsTests = await _testRepository.fetchPrelimsTests();
    final resultsResult = await _testRepository.fetchAllTestResults();
    prelimsTests.fold(
      (failure) {
        emit(PrelimsTestFetchedFailed(failure));
      },
      (tests) {
        final Map<int, TestResultModel> resultMap = {};

        resultsResult.fold((_) {}, (results) {
          for (final result in results) {
            resultMap[result.testId] = result;
          }
        });
        emit(PrelimsTestFetched(tests, resultMap));
      },
    );
  }
}
