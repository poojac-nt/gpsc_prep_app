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
  final String message;

  EditProfileFailure(this.message);
}
