part of 'course_purchased_users_bloc.dart';

abstract class CoursePurchasedUsersEvent {}

class FetchCoursePurchasedUsers extends CoursePurchasedUsersEvent {
  final int courseId;
  FetchCoursePurchasedUsers(this.courseId);
}
