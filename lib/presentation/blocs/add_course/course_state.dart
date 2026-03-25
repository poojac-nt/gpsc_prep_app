part of 'course_bloc.dart';

@immutable
abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class AddCourseSuccess extends CourseState {
  final CoursePayload course;

  AddCourseSuccess(this.course);
}

class AddCourseFailure extends CourseState {
  final String error;

  AddCourseFailure(this.error);
}

class FetchCoursesSuccess extends CourseState {
  final List<CourseModel> courses;

  FetchCoursesSuccess(this.courses);
}

class FetchCoursesFailure extends CourseState {
  final String error;

  FetchCoursesFailure(this.error);
}
