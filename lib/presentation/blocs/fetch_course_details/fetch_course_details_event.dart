part of 'fetch_course_details_bloc.dart';

@immutable
sealed class FetchCourseDetailsEvent {}

final class FetchCourseTestsAndResults extends FetchCourseDetailsEvent {
  final int courseId;

  FetchCourseTestsAndResults(this.courseId);
}
