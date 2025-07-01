import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final CacheManager _cache;
  final AuthRepository _authRepository;
  final SnackBarHelper _snackBarHelper;
  final CacheManager _cacheManager;
  final LogHelper _log;
  final _supabase = Supabase.instance.client;
  final ImagePicker picker = ImagePicker();
  UserModel? _currentUser;

  EditProfileBloc(
    this._cache,
    this._authRepository,
    this._snackBarHelper,
    this._cacheManager,
    this._log,
  ) : super(EditProfileInitial()) {
    on<LoadInitialProfile>(_onLoadInitialProfile);
    on<SaveProfileRequested>(_onSaveProfileRequested);
    on<EditImage>(_onUpdateImage);
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

  Future<void> _onUpdateImage(
    EditImage event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditImagePicking());
    try {
      /// Pick new image
      final XFile? pickedFile = await picker
          .pickImage(
            source: ImageSource.gallery,
            requestFullMetadata: false, // Improve performance
          )
          .onError((error, _) {
            _log.e('Image pick error: $error');
            return null;
          });

      if (pickedFile == null) {
        emit(EditImageUploadError('Please select an image'));
        return;
      }

      emit(EditImageUploading());

      /// Generate secure filename
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File imageFile = File(pickedFile.path);

      /// Upload with progress tracking
      await _supabase.storage
          .from('profile-picture')
          .upload('uploads/$fileName', imageFile);

      /// Get authenticated URL (more secure)
      final String newImageUrl = _supabase.storage
          .from('profile-picture')
          .getPublicUrl('uploads/$fileName');

      final String? oldImageUrl = _currentUser?.profilePicture;
      final authId = _currentUser?.authID;
      if (authId == null) throw Exception('User ID not found');

      await _supabase
          .from('users')
          .update({'profile_picture': newImageUrl})
          .eq('auth_id', authId);

      /// Delete old image from storage if it exists
      if (oldImageUrl != null && oldImageUrl.contains('profile-picture')) {
        try {
          final Uri uri = Uri.parse(oldImageUrl);
          final segments = uri.pathSegments;
          final bucketPathIndex = segments.indexOf('object') + 2;

          if (bucketPathIndex < 2 || bucketPathIndex >= segments.length) {
            throw Exception("Invalid image URL format.");
          }
          final filePath = segments.sublist(bucketPathIndex).join('/');
          _log.i('Attempting to delete file at path: $filePath');
          final result = await _supabase.storage.from('profile-picture').remove(
            [filePath],
          );
          _log.i('Supabase delete result: $result');
        } catch (e) {
          _log.e('Failed to delete image from Supabase', error: e);
        }
      }

      ///  Update local user in cache manager
      _cacheManager.setUser(
        UserModel(
          authID: _currentUser!.authID,
          role: _currentUser!.role,
          name: _currentUser!.name,
          email: _currentUser!.email,
          profilePicture: newImageUrl,
          number: _currentUser!.number,
          address: _currentUser!.address,
          id: _currentUser!.id,
        ),
      );
      _snackBarHelper.showSuccess('Profile Picture Updated Successfully');
      emit(EditImageUploaded(newImageUrl, _currentUser!));
    } catch (e) {
      _log.e('Image upload failed', error: e);
      emit(EditImageUploadError('Upload failed. Please try again'));
    }
  }
}
