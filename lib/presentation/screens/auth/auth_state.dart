part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Called when user is authenticated and user model is loaded
class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess(this.user);
}

/// Called when authentication fails (sign in / sign up)
class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

/// Called when user profile is being created
class AuthCreating extends AuthState {}

/// Called when user profile is successfully created
class AuthCreated extends AuthState {
  final UserModel user;

  AuthCreated(this.user);
}

/// Called when profile creation (e.g. Supabase RPC) fails
class AuthCreateFailure extends AuthState {
  final String message;

  AuthCreateFailure(this.message);
}

/// Called When Picking Image in registration screen
class ImagePicking extends AuthState {}

class ImageUploading extends AuthState {}

class ImageUploaded extends AuthState {
  final String imageUrl;

  ImageUploaded(this.imageUrl);
}

class ImageUploadError extends AuthState {
  final String message;

  ImageUploadError(this.message);
}
