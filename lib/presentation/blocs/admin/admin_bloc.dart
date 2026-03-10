import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc(this._adminRepository) : super(AdminInitial()) {
    on<FetchAdminStats>(_onFetchAdminStats);
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
}
