import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/usecases/get_available_language_usecase.dart';

import 'fetch_single_test_event.dart';
import 'fetch_single_test_state.dart';

class FetchSingleTestBloc
    extends Bloc<FetchSingleTestEvent, FetchSingleTestState> {
  final TestRepository _testRepository;

  FetchSingleTestBloc(this._testRepository)
    : super(FetchingSingleTestInitial()) {
    on<FetchSingleTestFromId>(_fetchSingleTestFromId);
    on<FetchSingleDescTestFromId>(_fetchSingleDescTestFromId);
  }

  Future<void> _fetchSingleTestFromId(
    FetchSingleTestFromId event,
    Emitter<FetchSingleTestState> emit,
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

  Future<void> _fetchSingleDescTestFromId(
    FetchSingleDescTestFromId event,
    Emitter<FetchSingleTestState> emit,
  ) async {
    emit(SingleTestFetching());
    final testResult = await _testRepository.fetchSingleDescTestFromId(
      event.testId,
    );
    await testResult.fold(
      (failure) {
        emit(SingleTestFetchingFailed(failure));
      },
      (test) async {
        emit(SingleDescTestFetched(test));
      },
    );
  }
}
