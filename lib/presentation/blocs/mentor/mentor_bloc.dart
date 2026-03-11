import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';

part 'mentor_event.dart';
part 'mentor_state.dart';

class MentorBloc extends Bloc<MentorEvent, MentorState> {
  final MentorRepository _mentorRepository;

  MentorBloc(this._mentorRepository) : super(MentorInitial()) {
    on<FetchMentorList>(_onFetchMentorList);
  }

  Future<void> _onFetchMentorList(
    FetchMentorList event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorListLoading());
    final result = await _mentorRepository.getMentorList();
    result.fold(
      (failure) => emit(MentorListError(failure.message)),
      (mentors) => emit(MentorListLoaded(mentors)),
    );
  }
}
