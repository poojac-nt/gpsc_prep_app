part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

class AuthInitial extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthInitial;

  @override
  int get hashCode => 0;
}

class AuthLoading extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthLoading;

  @override
  int get hashCode => 0;
}

class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSuccess && user.id == other.user.id;

  @override
  int get hashCode => user.id.hashCode;
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailure && message == other.message;

  @override
  int get hashCode => message.hashCode;
}
