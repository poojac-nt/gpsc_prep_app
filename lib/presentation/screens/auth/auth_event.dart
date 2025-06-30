part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class CreateUserRequested extends AuthEvent {
  final UserPayload userPayload;

  CreateUserRequested(this.userPayload);
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class LoadUserFromCache extends AuthEvent {}

class UpdateUserProfile extends AuthEvent {
  final UserModel updateUser;

  UpdateUserProfile(this.updateUser);
}

class LogOutRequested extends AuthEvent {}

class PickImage extends AuthEvent {}
