import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final CacheManager _cache;
  final AuthRepository _authRepository;
  final SnackBarHelper _snackBarHelper;
  final LogHelper _log;
  final _supabase = getIt<SupabaseHelper>().supabase;
  final ImagePicker picker = ImagePicker();
  UserModel? _currentUser;

  EditProfileBloc(
    this._cache,
    this._authRepository,
    this._snackBarHelper,
    this._log,
  ) : super(EditProfileInitial()) {
    on<SaveProfileRequested>(_onSaveProfileRequested);
    on<EditImage>(_onUpdateImage);
    on<LoadInitialProfile>(_onLoadInitialProfile);
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
      return;
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
      _log.e('Profile save error', error: e);
    }
  }

  Future<void> _onUpdateImage(
    EditImage event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditImagePicking());

    try {
      // Pick new image
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

      // Generate secure filename and upload path
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'uploads/$fileName';
      final File imageFile = File(pickedFile.path);

      // Upload new image
      await _supabase.storage
          .from('profile-picture')
          .upload(storagePath, imageFile);

      // Get new public URL
      final String newImageUrl = _supabase.storage
          .from('profile-picture')
          .getPublicUrl(storagePath);

      final String? oldImageUrl = _currentUser?.profilePicture;
      final String? authId = _currentUser?.authID;
      if (authId == null) throw Exception('User ID not found');

      // Update image URL in database
      await _supabase
          .from('users')
          .update({'profile_picture': newImageUrl})
          .eq('auth_id', authId);

      // Delete old image if it exists
      if (oldImageUrl != null && oldImageUrl.contains('profile-picture')) {
        try {
          final oldImagePath = _extractStoragePathFromUrl(oldImageUrl);
          _log.i('Attempting to delete old image at path: $oldImagePath');
          final result = await _supabase.storage.from('profile-picture').remove(
            [oldImagePath!],
          );
          _log.i('Supabase delete result: $result');
        } catch (e) {
          _log.e('Failed to delete old image from Supabase', error: e);
        }
      }

      // Update user in cache
      final updatedUser = _currentUser!.copyWith(profilePicture: newImageUrl);
      _cache.setUser(updatedUser);
      _currentUser = updatedUser;

      _snackBarHelper.showSuccess('Profile Picture Updated Successfully');
      emit(EditImageUploaded(newImageUrl, updatedUser));
    } catch (e) {
      _log.e('Image upload failed', error: e);
      emit(EditImageUploadError('Upload failed. Please try again'));
    }
  }

  /// Helper method to extract the storage path from a public URL
  String? _extractStoragePathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final index = uri.pathSegments.indexOf('profile-picture');
      if (index == -1 || index + 1 >= uri.pathSegments.length) return null;
      return uri.pathSegments.sublist(index + 1).join('/');
    } catch (e) {
      _log.e('Error parsing old image URL for deletion', error: e);
      return null;
    }
  }
}
