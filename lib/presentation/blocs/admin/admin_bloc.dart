import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc(this._adminRepository) : super(AdminInitial()) {
    on<FetchAdminStats>(_onFetchAdminStats);
    on<FetchMentorList>(_onFetchMentorList);
    on<UpdateMentor>(_onUpdateMentor);
    on<DeleteMentor>(_onDeleteMentor);
  }

  Future<void> _onFetchAdminStats(
    FetchAdminStats event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminStatsLoading());
    final result = await _adminRepository.getAdminStats();
    result.fold(
      (failure) => emit(AdminStatsError(failure.message)),
      (stats) => emit(AdminStatsLoaded(stats)),
    );
  }

  Future<void> _onFetchMentorList(
    FetchMentorList event,
    Emitter<AdminState> emit,
  ) async {
    emit(MentorListLoading());
    final result = await _adminRepository.getMentorList();
    result.fold(
      (failure) => emit(MentorListError(failure.message)),
      (mentors) => emit(MentorListLoaded(mentors)),
    );
  }

  Future<void> _onUpdateMentor(
    UpdateMentor event,
    Emitter<AdminState> emit,
  ) async {
    emit(MentorSaving());
    final result = await _adminRepository.updateMentor(
      userId: event.userId,
      name: event.name,
      bio: event.bio,
      subjectExpertise: event.subjectExpertise,
      isActive: event.isActive,
    );
    result.fold(
      (failure) => emit(MentorOperationError(failure.message)),
      (mentor) => emit(MentorUpdateSuccess(mentor)),
    );
  }

  Future<void> _onDeleteMentor(
    DeleteMentor event,
    Emitter<AdminState> emit,
  ) async {
    emit(MentorSaving());
    final result = await _adminRepository.deleteMentor(event.userId);
    result.fold(
      (failure) => emit(MentorOperationError(failure.message)),
      (_) => emit(MentorDeleteSuccess()),
    );
  }
}
