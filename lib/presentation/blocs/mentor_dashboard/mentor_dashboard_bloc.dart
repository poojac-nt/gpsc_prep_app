import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_dashbord_data.dart';

part 'mentor_dashboard_event.dart';
part 'mentor_dashboard_state.dart';

class MentorDashboardBloc
    extends Bloc<MentorDashboardEvent, MentorDashboardState> {
  final MentorRepository _mentorRepository;

  MentorDashboardBloc(this._mentorRepository)
    : super(MentorDashboardInitial()) {
    on<FetchMentorDashboardData>(_onFetchMentorDashboardData);
  }

  Future<void> _onFetchMentorDashboardData(
    FetchMentorDashboardData event,
    Emitter<MentorDashboardState> emit,
  ) async {
    emit(MentorDashboardLoading());
    try {
      final result = await _mentorRepository.fetchMentorDashboardData();
      result.fold(
        (failure) => emit(MentorDashboardError(failure.message)),
        (data) => emit(MentorDashboardLoaded(data)),
      );
    } catch (e) {
      emit(MentorDashboardError(e.toString()));
    }
  }
}
