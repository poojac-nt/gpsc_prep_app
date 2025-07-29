part of 'edit_profile_bloc.dart';

@immutable
sealed class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileLoaded extends EditProfileState {
  final UserModel user;

  EditProfileLoaded(this.user);
}

class EditProfileSaving extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final UserModel user;

  EditProfileSuccess(this.user);
}

class EditProfileFailure extends EditProfileState {
  final Failure failure;

  EditProfileFailure(this.failure);
}

class EditImagePicking extends EditProfileState {}

class EditImageUploading extends EditProfileState {}

class EditImageUploaded extends EditProfileState {
  final String imageUrl;
  final UserModel user;

  EditImageUploaded(this.imageUrl, this.user);
}

class EditImageUploadError extends EditProfileState {
  final Failure failure;

  EditImageUploadError(this.failure);
}
