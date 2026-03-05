part of 'course_bloc.dart';

abstract class CourseEvent {}

class AddCourseRequested extends CourseEvent {
  final String name;
  final String? description;
  final String testType;

  AddCourseRequested({
    required this.name,
    this.description,
    required this.testType,
  });
}

class FetchCoursesRequested extends CourseEvent {}
