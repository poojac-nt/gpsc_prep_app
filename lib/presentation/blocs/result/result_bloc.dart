import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';

part 'result_event.dart';
part 'result_state.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final TestRepository _testRepository;
  final _log = LogHelper();

  ResultBloc(this._testRepository) : super(ResultStateInitial()) {
    on<FetchResultData>(_onFetchResultData);
  }

  Future<void> _onFetchResultData(
    FetchResultData event,
    Emitter<ResultState> emit,
  ) async {
    emit(ResultLoading());

    // Fetch both requests concurrently
    final results = await _testRepository.getUserTestResultWithTopScore(
      event.testId,
    );

    results.fold(
      (failure) {
        _log.e('Failed to fetch result data: ${failure.message}');
        emit(SingleResultFailure(failure));
      },
      (data) {
        emit(ResultDataSuccess(result: data));
      },
    );
  }
}
