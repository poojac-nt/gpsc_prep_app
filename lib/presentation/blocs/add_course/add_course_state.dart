part of 'add_course_bloc.dart';

abstract class AddCourseState {}

class AddCourseInitial extends AddCourseState {}

class AddCourseLoading extends AddCourseState {}

class AddCourseSuccess extends AddCourseState {
  final CourseModel course;

  AddCourseSuccess(this.course);
}

class AddCourseFailure extends AddCourseState {
  final String error;

  AddCourseFailure(this.error);
}
