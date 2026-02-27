part of 'peer_review_bloc.dart';

abstract class PeerReviewState {}

class PeerReviewInitial extends PeerReviewState {}

class PeerReviewLoading extends PeerReviewState {}

class PeerReviewLoaded extends PeerReviewState {
  final List<PeerReviewModel> peerReviews;

  PeerReviewLoaded(this.peerReviews);
}

class PeerReviewError extends PeerReviewState {
  final String message;

  PeerReviewError(this.message);
}
