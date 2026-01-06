import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/option_matrix_model.dart';
import 'package:meta/meta.dart';
import 'package:gpsc_prep_app/domain/entities/option_matrix_model.dart';
import '../../../../../core/error/failure.dart';
part 'bar_chart_event.dart';
part 'bar_chart_state.dart';

class BarChartBloc extends Bloc<BarChartEvent, BarChartState> {
  final TestRepository _testRepository;

  BarChartBloc(this._testRepository) : super(BarChartInitial()) {
    on<FetchOptionMatrix>(_onFetchOptionMatrix);
  }

  Future<void> _onFetchOptionMatrix(
    FetchOptionMatrix event,
    Emitter<BarChartState> emit,
  ) async {
    emit(OptionMatrixLoading());
    final result = await _testRepository.optionMatrixForQuestion(
      testId: event.testId,
    );
    await result.fold(
      (failure) async {
        emit(OptionMatrixResultFailure(failure));
      },
      (optionMatrix) async {
        emit(OptionMatrixSuccess(optionMatrix));
      },
    );
  }
}
