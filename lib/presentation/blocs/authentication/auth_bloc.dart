import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc_event.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';
import 'package:image_picker/image_picker.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final CacheManager _cache;
  final ImagePicker picker = ImagePicker();
  static final _supabase = getIt<SupabaseHelper>().supabase;
  static final _snackBar = getIt<SnackBarHelper>();

  AuthBloc(this._authRepository, this._cache) : super(AuthInitial()) {
    on<LoginRequested>(_login);
    on<LogOutRequested>(_logOutRequest);
    on<LoadUserFromCache>(_loadUserFromCache);
    on<CreateUserRequested>(_createUser);
    on<DeleteUserRequested>(_onDeleteUserRequested);
    on<PickImage>(_onPickAndUploadImage);
    on<ResetPasswordRequested>(_onResetPassword);
    on<RequestResetPasswordEvent>(_onRequestResetPassword);
  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final userExist = await _authRepository.doesUserExist(event.email);
      if (!userExist) {
        emit(AuthFailure("User does not exist."));
        return;
      }

      final result = await _authRepository.login(event.email, event.password);
      result.fold((failure) => emit(AuthFailure(failure.message)), (user) {
        _cache.setUser(user);
        emit(AuthSuccess(user));
      });
    } catch (e) {
      emit(AuthFailure("An unexpected error occurred. $e"));
    }
  }

  Future<void> _loadUserFromCache(
    LoadUserFromCache event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _cache.getInitUser();
    if (user != null) {
      emit(AuthSuccess(user));
    } else {
      emit(AuthFailure('No User Found in Cache Memory'));
    }
  }

  Future<void> _createUser(
    CreateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthCreatingAccount());
    final userExist = await _authRepository.doesUserExist(
      event.userPayload.email,
    );
    if (userExist) {
      _snackBar.showError('Email is Already Registered');
      emit(AuthAccountCreateError('Email is Already Registered'));
      return;
    }
    final result = await _authRepository.createUser(event.userPayload);

    result.fold((failure) => emit(AuthAccountCreateError(failure.message)), (
      user,
    ) {
      _cache.setUser(user);
      emit(AuthAccountCreated(user));
    });
  }

  Future<void> _onPickAndUploadImage(
    PickImage event,
    Emitter<AuthState> emit,
  ) async {
    emit(ImagePicking());
    try {
      XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        emit(ImageUploadFailed('No image selected.'));
        return;
      }
      emit(ImageUploading());
      final File imageFile = File(pickedFile.path);
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage
          .from(SupabaseKeys.profilePicture)
          .upload('uploads/$fileName', imageFile);

      final String publicUrl = _supabase.storage
          .from(SupabaseKeys.profilePicture)
          .getPublicUrl('uploads/$fileName');
      emit(ImageUploaded(publicUrl));
    } catch (e) {
      emit(ImageUploadFailed('Failed to upload image: $e'));
    }
  }

  Future<void> _logOutRequest(
    LogOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _supabase.auth.signOut();
      _cache.clearUser();
      getIt<DashboardBloc>().add(DashBoardInitial());
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure('Logout failed: $e'));
    }
  }

  Future<void> _onDeleteUserRequested(
    DeleteUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(DeleteUserLoading());
    try {
      final deleted = await _authRepository.deleteUser();
      if (deleted == true) {
        _cache.clearUser();
        emit(DeleteUserSuccess());
      }
    } catch (e) {
      emit(DeleteUserFailure(e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResetPasswordLoading());
    try {
      await _authRepository.resetPassword(event.newPassword);
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(ResetPasswordFailure('Failed to reset password: $e'));
    }
  }

  Future<void> _onRequestResetPassword(
    RequestResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(RequestResetPasswordLoading());
    try {
      bool emailExists = await _authRepository.doesUserExist(event.email);
      if (emailExists) {
        await _authRepository.requestResetPassword(event.email);
        emit(RequestResetPasswordSuccess());
      } else {
        emit(RequestResetPasswordFailure('This Email is not registered'));
      }
    } catch (e) {
      emit(RequestResetPasswordFailure('Failed to send reset link: $e'));
    }
  }
}
