import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_peer_review_model.dart';
import 'package:gpsc_prep_app/data/repositories/peer_review_repository.dart';

part 'detailed_peer_review_event.dart';
part 'detailed_peer_review_state.dart';

class DetailedPeerReviewBloc
    extends Bloc<DetailedPeerReviewEvent, DetailedPeerReviewState> {
  final PeerReviewRepository _peerReviewRepository;

  DetailedPeerReviewBloc(this._peerReviewRepository)
    : super(DetailedPeerReviewInitial()) {
    on<FetchDetailedPeerReview>(_onFetchDetailedPeerReview);
  }

  Future<void> _onFetchDetailedPeerReview(
    FetchDetailedPeerReview event,
    Emitter<DetailedPeerReviewState> emit,
  ) async {
    emit(DetailedPeerReviewLoading());
    final result = await _peerReviewRepository.detailedPeerReview(
      answerId: event.answerId,
    );

    result.fold(
      (failure) => emit(DetailedPeerReviewError(failure.message)),
      (detail) => emit(DetailedPeerReviewLoaded(detail)),
    );
  }
}
