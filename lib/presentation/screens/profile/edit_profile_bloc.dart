import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:meta/meta.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final CacheManager _cache;
  final AuthRepository _authRepository;
  final SnackBarHelper _snackBarHelper;

  UserModel? _currentUser;

  EditProfileBloc(this._cache, this._authRepository, this._snackBarHelper)
    : super(EditProfileInitial()) {
    on<LoadInitialProfile>(_onLoadInitialProfile);
    on<SaveProfileRequested>(_onSaveProfileRequested);
  }

  Future<void> _onLoadInitialProfile(
    LoadInitialProfile event,
    Emitter<EditProfileState> emit,
  ) async {
    final user = await _cache.getInitUser();
    if (user != null) {
      _currentUser = user;
      emit(EditProfileLoaded(user));
    } else {
      emit(EditProfileFailure('User Not Found'));
    }
  }

  Future<void> _onSaveProfileRequested(
    SaveProfileRequested event,
    Emitter<EditProfileState> emit,
  ) async {
    if (_currentUser == null) {
      emit(EditProfileFailure('No User Data to Update'));
    }
    emit(EditProfileSaving());
    try {
      final result = await _authRepository.updateUserInfo(event.updatedUser);
      result.fold((failure) => emit(EditProfileFailure(failure.message)), (
        user,
      ) {
        _cache.setUser(user);
        _snackBarHelper.showSuccess('Information Updated Successfully');
        emit(EditProfileSuccess(user));
        emit(EditProfileLoaded(user));
      });
    } catch (e) {
      emit(EditProfileFailure('Failed to Save profile :$e'));
    }
  }
}
