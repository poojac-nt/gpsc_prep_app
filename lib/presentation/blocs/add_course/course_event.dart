import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';

part of 'course_bloc.dart';

@immutable
abstract class CourseEvent {}

class AddCourseRequested extends CourseEvent {
  final String name;
  final String? description;
  final CourseTestType testType;
  final int? priceSingle;
  final int? priceDual;

  AddCourseRequested({
    required this.name,
    this.description,
    required this.testType,
    this.priceSingle,
    this.priceDual,
  });
}

class FetchCoursesRequested extends CourseEvent {}
