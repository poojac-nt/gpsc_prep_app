part of 'edit_profile_bloc.dart';

@immutable
sealed class EditProfileEvent {}

class SaveProfileRequested extends EditProfileEvent {
  final UserPayload updatedUser;

  SaveProfileRequested(this.updatedUser);
}

class LoadInitialProfile extends EditProfileEvent {}

class EditImage extends EditProfileEvent {}
