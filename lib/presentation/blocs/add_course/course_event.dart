part of 'course_bloc.dart';

abstract class CourseEvent {}

class AddCourseRequested extends CourseEvent {
  final String name;
  final String? description;

  AddCourseRequested({required this.name, this.description});
}

class FetchCoursesRequested extends CourseEvent {}
