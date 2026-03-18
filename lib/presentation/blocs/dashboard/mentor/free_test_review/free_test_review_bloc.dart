import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'free_test_review_event.dart';
import 'free_test_review_state.dart';

class FreeTestReviewBloc extends Bloc<FreeTestReviewEvent, FreeTestReviewState> {
  final MentorRepository _mentorRepository;

  FreeTestReviewBloc(this._mentorRepository) : super(FreeTestReviewInitial()) {
    on<FetchFreeTestReviews>(_onFetchFreeTestReviews);
  }

  Future<void> _onFetchFreeTestReviews(
    FetchFreeTestReviews event,
    Emitter<FreeTestReviewState> emit,
  ) async {
    emit(FreeTestReviewLoading());
    final result = await _mentorRepository.fetchSubmittedFreeDescTests();
    result.fold(
      (failure) => emit(FreeTestReviewError(failure.message)),
      (data) => emit(FreeTestReviewLoaded(data)),
    );
  }
}
