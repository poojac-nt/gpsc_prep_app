import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'free_test_review_event.dart';
import 'free_test_review_state.dart';

class FreeTestReviewBloc extends Bloc<FreeTestReviewEvent, FreeTestReviewState> {
  final MentorRepository _mentorRepository;

  FreeTestReviewBloc(this._mentorRepository) : super(FreeTestReviewInitial()) {
    on<FetchFreeTestReviews>(_onFetchFreeTestReviews);
    on<LoadMoreFreeTestReviews>(_onLoadMoreFreeTestReviews);
  }

  Future<void> _onFetchFreeTestReviews(
    FetchFreeTestReviews event,
    Emitter<FreeTestReviewState> emit,
  ) async {
    emit(FreeTestReviewLoading());
    final result = await _mentorRepository.fetchSubmittedFreeDescTests(
      offset: 0,
      limit: 20,
    );
    result.fold(
      (failure) => emit(FreeTestReviewError(failure.message)),
      (data) => emit(
        FreeTestReviewLoaded(
          data,
          hasReachedMax: data.length < 20,
          offset: data.length,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreFreeTestReviews(
    LoadMoreFreeTestReviews event,
    Emitter<FreeTestReviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FreeTestReviewLoaded ||
        currentState.hasReachedMax ||
        currentState.isFetchingMore) {
      return;
    }

    emit(currentState.copyWith(isFetchingMore: true));

    final result = await _mentorRepository.fetchSubmittedFreeDescTests(
      offset: currentState.offset,
      limit: 20,
    );

    result.fold((failure) {
      emit(currentState.copyWith(isFetchingMore: false));
    }, (newData) {
      if (newData.isEmpty) {
        emit(
          currentState.copyWith(hasReachedMax: true, isFetchingMore: false),
        );
      } else {
        emit(
          FreeTestReviewLoaded(
            currentState.submissions + newData,
            hasReachedMax: newData.length < 20,
            offset: currentState.offset + newData.length,
            isFetchingMore: false,
          ),
        );
      }
    });
  }
}
