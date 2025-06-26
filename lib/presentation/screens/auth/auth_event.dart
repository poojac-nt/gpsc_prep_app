part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequested &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}

class LogOutRequested extends AuthEvent {
  LogOutRequested();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogOutRequested;
  }

  @override
  int get hashCode => 0;
}
