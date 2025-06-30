part of 'edit_profile_bloc.dart';

@immutable
sealed class EditProfileEvent {}

class LoadInitialProfile extends EditProfileEvent {}

class ProfileFieldChanged extends EditProfileEvent {
  final UserPayload updatedUser;

  ProfileFieldChanged(this.updatedUser);
}

class SaveProfileRequested extends EditProfileEvent {
  final UserPayload updatedUser;

  SaveProfileRequested(this.updatedUser);
}
