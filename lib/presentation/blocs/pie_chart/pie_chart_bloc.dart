import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/presentation/blocs/pie_chart/pie_chart_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/pie_chart/pie_chart_state.dart';

class PieChartBloc extends Bloc<PieChartEvent, PieChartState> {
  final TestRepository _testRepository;

  PieChartBloc(this._testRepository) : super(PieChartInitial()) {
    on<FetchCorrectnessCountsEvent>(_onFetchCorrectnessCounts);
  }

  Future<void> _onFetchCorrectnessCounts(
    FetchCorrectnessCountsEvent event,
    Emitter<PieChartState> emit,
  ) async {
    emit(CorrectnessCountsLoading());

    final result = await _testRepository.fetchQuestionCorrectnessCounts(
      event.testId,
    );

    result.fold((failure) => emit(PieChartResultFailure(failure)), (
      List<Map<String, dynamic>> countsList,
    ) {
      emit(CorrectnessCountsSuccess(countsList));
    });
  }
}
