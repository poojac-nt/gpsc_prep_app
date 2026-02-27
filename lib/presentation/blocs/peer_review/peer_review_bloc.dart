import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/domain/entities/peer_review_model.dart';
import 'package:gpsc_prep_app/data/repositories/peer_review_repository.dart';

part 'peer_review_event.dart';
part 'peer_review_state.dart';

class PeerReviewBloc extends Bloc<PeerReviewEvent, PeerReviewState> {
  final PeerReviewRepository _peerReviewRepository;

  PeerReviewBloc(this._peerReviewRepository) : super(PeerReviewInitial()) {
    on<FetchPeerReviews>(_onFetchPeerReviews);
  }

  Future<void> _onFetchPeerReviews(
    FetchPeerReviews event,
    Emitter<PeerReviewState> emit,
  ) async {
    emit(PeerReviewLoading());
    final result = await _peerReviewRepository.peerReview(
      testId: event.testId,
      questionId: event.questionId,
    );

    result.fold(
      (failure) => emit(PeerReviewError(failure.message)),
      (peerReviews) => emit(PeerReviewLoaded(peerReviews)),
    );
  }
}
