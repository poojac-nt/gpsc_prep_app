import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/mains_test_review_model.dart';

part 'mains_test_review_event.dart';
part 'mains_test_review_state.dart';

class MainsTestReviewBloc
    extends Bloc<MainsTestReviewEvent, MainsTestReviewState> {
  final TestRepository _testRepository;
  final _log = LogHelper();

  MainsTestReviewBloc(this._testRepository) : super(MainsTestReviewInitial()) {
    on<FetchMainsTestReview>(_onFetchResult);
  }

  Future<void> _onFetchResult(
    FetchMainsTestReview event,
    Emitter<MainsTestReviewState> emit,
  ) async {
    emit(MainsTestReviewLoading());

    final result = await _testRepository.fetchDescriptiveTestReview(
      event.testId,
    );

    result.fold(
      (failure) {
        _log.e('Failed to fetch descriptive test result: ${failure.message}');
        emit(MainsTestReviewError(failure.message));
      },
      (data) {
        emit(MainsTestReviewLoaded(data));
      },
    );
  }
}
