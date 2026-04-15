part of 'fetch_course_details_bloc.dart';

@immutable
sealed class FetchCourseDetailsState {}

final class FetchCourseDetailsInitial extends FetchCourseDetailsState {}

final class FetchCourseDetailsLoading extends FetchCourseDetailsState {}

final class FetchCourseDetailsSuccess extends FetchCourseDetailsState {
  final CourseModel courseDetails;
  final Map<int, List<DescAnswerModel>> answersMap;
  final Map<int, MainsTestReviewModel?> reviewsMap;

  FetchCourseDetailsSuccess({
    required this.courseDetails,
    required this.answersMap,
    required this.reviewsMap,
  });
}

final class FetchCourseDetailsFailure extends FetchCourseDetailsState {
  final Failure errorMessage;

  FetchCourseDetailsFailure(this.errorMessage);
}
