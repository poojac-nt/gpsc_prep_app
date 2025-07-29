part of '../../blocs/authentication/auth_bloc.dart';

@immutable
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Called when user is authenticated and user model is loaded
class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess(this.user);
}

class Unauthenticated extends AuthState {}

/// Called when authentication fails (sign in / sign up)
class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

/// Called when user profile is being created
class AuthCreatingAccount extends AuthState {}

/// Called when user profile is successfully created
class AuthAccountCreated extends AuthState {
  final UserModel user;

  AuthAccountCreated(this.user);
}

/// Called when profile creation (e.g. Supabase RPC) fails
class AuthAccountCreateError extends AuthState {
  final String message;

  AuthAccountCreateError(this.message);
}

/// Called When Picking Image in registration screen
class ImagePicking extends AuthState {}

class ImageUploading extends AuthState {}

class ImageUploaded extends AuthState {
  final String imageUrl;

  ImageUploaded(this.imageUrl);
}

class ImageUploadFailed extends AuthState {
  final String message;

  ImageUploadFailed(this.message);
}

///Called when deleting the user

class DeleteUserInitial extends AuthState {}

class DeleteUserLoading extends AuthState {}

class DeleteUserSuccess extends AuthState {}

class DeleteUserFailure extends AuthState {
  final String error;

  DeleteUserFailure(this.error);
}
