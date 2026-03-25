import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/peer_review_repository.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_peer_review_model.dart';

part 'submit_peer_review_event.dart';
part 'submit_peer_review_state.dart';

class SubmitPeerReviewBloc
    extends Bloc<SubmitPeerReviewEvent, SubmitPeerReviewState> {
  final PeerReviewRepository _peerReviewRepository;

  SubmitPeerReviewBloc(this._peerReviewRepository)
    : super(SubmitPeerReviewInitial()) {
    on<SubmitPeerReview>(_onSubmitPeerReview);
    on<ResetSubmitPeerReviewState>(
      (event, emit) => emit(SubmitPeerReviewInitial()),
    );
  }

  Future<void> _onSubmitPeerReview(
    SubmitPeerReview event,
    Emitter<SubmitPeerReviewState> emit,
  ) async {
    emit(SubmitPeerReviewLoading());
    final result = await _peerReviewRepository.insertPeerReview(
      answerId: event.answerId,
      reviewerId: event.reviewerId,
      comment: event.comment,
    );

    result.fold(
      (failure) => emit(SubmitPeerReviewError(failure.message)),
      (comment) => emit(SubmitPeerReviewSuccess(comment)),
    );
  }
}

