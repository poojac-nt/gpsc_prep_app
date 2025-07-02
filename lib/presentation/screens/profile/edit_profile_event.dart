part of 'edit_profile_bloc.dart';

@immutable
sealed class EditProfileEvent {}

class LoadInitialProfile extends EditProfileEvent {}

class SaveProfileRequested extends EditProfileEvent {
  final UserPayload updatedUser;

  SaveProfileRequested(this.updatedUser);
}

class EditImage extends EditProfileEvent {}
