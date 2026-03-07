import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'pending_submissions_event.dart';
import 'pending_submissions_state.dart';

class PendingSubmissionsBloc
    extends Bloc<PendingSubmissionsEvent, PendingSubmissionsState> {
  final MentorRepository _repository;

  PendingSubmissionsBloc(this._repository)
    : super(PendingSubmissionsInitial()) {
    on<FetchPendingSubmissions>(_onFetchPendingSubmissions);
  }

  Future<void> _onFetchPendingSubmissions(
    FetchPendingSubmissions event,
    Emitter<PendingSubmissionsState> emit,
  ) async {
    emit(PendingSubmissionsLoading());
    final result = await _repository.fetchPendingSubmissions();
    result.fold(
      (failure) => emit(PendingSubmissionsError(failure.message)),
      (submissions) => emit(PendingSubmissionsLoaded(submissions)),
    );
  }
}
