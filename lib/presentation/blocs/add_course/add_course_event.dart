part of 'add_course_bloc.dart';

abstract class AddCourseEvent {}

class AddCourseRequested extends AddCourseEvent {
  final String name;
  final String? description;

  AddCourseRequested({required this.name, this.description});
}
