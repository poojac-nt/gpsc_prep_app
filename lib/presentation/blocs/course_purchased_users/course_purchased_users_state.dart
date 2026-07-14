part of 'course_purchased_users_bloc.dart';

abstract class CoursePurchasedUsersState {}

class CoursePurchasedUsersInitial extends CoursePurchasedUsersState {}

class CoursePurchasedUsersLoading extends CoursePurchasedUsersState {}

class CoursePurchasedUsersLoaded extends CoursePurchasedUsersState {
  final List<UserModel> users;

  CoursePurchasedUsersLoaded(this.users);
}

class CoursePurchasedUsersError extends CoursePurchasedUsersState {
  final Failure message;

  CoursePurchasedUsersError(this.message);
}
