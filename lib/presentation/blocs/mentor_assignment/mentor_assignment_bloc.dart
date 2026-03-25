import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'package:gpsc_prep_app/data/models/payloads/mentor_assign_payload.dart';

part 'mentor_assignment_event.dart';
part 'mentor_assignment_state.dart';

class MentorAssignmentBloc
    extends Bloc<MentorAssignmentEvent, MentorAssignmentState> {
  final MentorRepository _repository;

  MentorAssignmentBloc(this._repository) : super(MentorAssignmentInitial()) {
    on<AssignMentorsToSubmissions>(_onAssignMentorsToSubmissions);
  }

  Future<void> _onAssignMentorsToSubmissions(
    AssignMentorsToSubmissions event,
    Emitter<MentorAssignmentState> emit,
  ) async {
    emit(MentorAssignmentLoading());
    final result = await _repository.assignMentorToTest(
      payloads: event.payloads,
    );
    result.fold(
      (failure) => emit(MentorAssignmentError(failure.message)),
      (_) => emit(MentorsAssignedSuccessfully()),
    );
  }
}
