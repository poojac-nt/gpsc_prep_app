import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/course_repository.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_answer_model.dart';
import 'package:gpsc_prep_app/domain/entities/mains_test_review_model.dart';
import 'package:meta/meta.dart';

part 'fetch_course_details_event.dart';
part 'fetch_course_details_state.dart';

class FetchCourseDetailsBloc
    extends Bloc<FetchCourseDetailsEvent, FetchCourseDetailsState> {
  final CourseRepository _courseRepository;
  final TestRepository _testRepository;

  FetchCourseDetailsBloc(this._courseRepository, this._testRepository)
    : super(FetchCourseDetailsInitial()) {
    on<FetchCourseTestsAndResults>(_fetchTestsAndResults);
  }

  Future<void> _fetchTestsAndResults(
    FetchCourseTestsAndResults event,
    Emitter<FetchCourseDetailsState> emit,
  ) async {
    emit(FetchCourseDetailsLoading());
    try {
      final response = await _courseRepository.fetchCourseWithTests(
        event.courseId,
      );

      await response.fold(
        (failure) async => emit(FetchCourseDetailsFailure(failure)),
        (courseDetails) async {
          final Map<int, List<DescAnswerModel>> answersMap = {};
          final Map<int, MainsTestReviewModel?> reviewsMap = {};

          // 1. Fetch descriptive test submissions
          final submissionsResult =
              await _testRepository.fetchDescriptiveTestSubmissions();

          submissionsResult.fold((_) {}, (submittedIds) {
            for (final id in submittedIds) {
              answersMap[id] = [
                DescAnswerModel(
                  userId: 0,
                  testId: id,
                  questionId: 0,
                  answer: 'Submitted',
                ),
              ];
            }
          });

          // 2. Fetch reviews for each descriptive test in this course if submitted
          final descriptiveTests = courseDetails.tests?.descriptive ?? [];
          for (final test in descriptiveTests) {
            if (answersMap.containsKey(test.id)) {
              final reviewResult = await _testRepository
                  .fetchDescriptiveTestReview(test.id);
              reviewResult.fold(
                (failure) => reviewsMap[test.id] = null,
                (review) => reviewsMap[test.id] = review,
              );
            }
          }

          emit(
            FetchCourseDetailsSuccess(
              courseDetails: courseDetails,
              answersMap: answersMap,
              reviewsMap: reviewsMap,
            ),
          );
        },
      );
    } catch (e) {
      emit(FetchCourseDetailsFailure(Failure(e.toString())));
    }
  }
}
