import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc_state.dart';

class DashboardBloc extends Bloc<DashboardBlocEvent, DashboardBlocState> {
  final TestRepository _testRepository;

  DashboardBloc(this._testRepository) : super(FetchingAttemptedTests()) {
    on<FetchAttemptedTests>(_fetchAttemptedTests);
  }

  Future<void> _fetchAttemptedTests(
    DashboardBlocEvent event,
    Emitter<DashboardBlocState> emit,
  ) async {
    emit(FetchingAttemptedTests());
    try {
      final result = await _testRepository.fetchAllAttemptedTests();
      result.fold(
        (failure) {
          emit(AttemptedTestsFetchedFailed(failure));
        },
        (tests) {
          final int totalTest = tests['attempted_tests'];
          final double avgScore = tests['average_score'];
          emit(
            AttemptedTestsFetched(totalTests: totalTest, avgScore: avgScore),
          );
        },
      );
    } catch (e) {
      print("error while fetching attempted tests $e");
    }
  }
}
