import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/difficulty_wise_review_per_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';

part 'result_event.dart';
part 'result_state.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final TestRepository _testRepository;
  final SnackBarHelper _snackBarHelper;
  final _log = LogHelper();

  ResultBloc(this._testRepository, this._snackBarHelper)
    : super(ResultStateInitial()) {
    on<FetchResultData>(_onFetchResultData);
  }

  Future<void> _onFetchResultData(
    FetchResultData event,
    Emitter<ResultState> emit,
  ) async {
    emit(ResultLoading());

    // Fetch both requests concurrently
    final results = await Future.wait([
      _testRepository.getUserTestResultWithTopScore(event.testId),
      _testRepository.fetchUserTestReview(event.testId),
      _testRepository.fetchUserTestReviewByQuestionType(event.testId),
      _testRepository.fetchUserTestReviewBySubject(event.testId),
    ]);

    final topScoreResult =
        results[0] as Either<Failure, TestResultWithTopScoreModel?>;
    final reviewResult =
        results[1] as Either<Failure, List<TestReviewAnalytics>?>;
    final questionTypeResult =
        results[2] as Either<Failure, List<TestReviewAnalytics>?>;
    final subjectWiseResult =
        results[3] as Either<Failure, List<TestReviewAnalytics>?>;

    topScoreResult.fold((failure) => emit(SingleResultFailure(failure)), (
      data,
    ) {
      // If top score succeeds, check review result
      List<TestReviewAnalytics>? reviews;
      reviewResult.fold(
        (failure) {
          _log.e(
            'Failed to fetch question type review data: ${failure.toString()}',
          );
          _snackBarHelper.showError(
            'Failed to load  question type review data. Please try again later.',
          );
        },
        (reviewData) {
          reviews = reviewData;
        },
      );
      List<TestReviewAnalytics>? reviewsByQuestionType;
      questionTypeResult.fold(
        (failure) {
          _log.e('Failed to fetch review data: ${failure.toString()}');
          _snackBarHelper.showError(
            'Failed to load review data. Please try again later.',
          );
        },
        (reviewData) {
          reviewsByQuestionType = reviewData;
        },
      );
      List<TestReviewAnalytics>? reviewsBySubject;
      subjectWiseResult.fold(
        (failure) {
          _log.e('Failed to fetch review data: ${failure.toString()}');
          _snackBarHelper.showError(
            'Failed to load review data. Please try again later.',
          );
        },
        (reviewData) {
          reviewsBySubject = reviewData;
        },
      );
      emit(
        ResultDataSuccess(
          result: data!,
          reviewByDifficulty: reviews,
          reviewByQuestionType: reviewsByQuestionType,
          reviewBySubject: reviewsBySubject,
        ),
      );
    });
  }
}
