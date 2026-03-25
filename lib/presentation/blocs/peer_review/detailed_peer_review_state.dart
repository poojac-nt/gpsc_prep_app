part of 'detailed_peer_review_bloc.dart';

abstract class DetailedPeerReviewState {}

class DetailedPeerReviewInitial extends DetailedPeerReviewState {}

class DetailedPeerReviewLoading extends DetailedPeerReviewState {}

class DetailedPeerReviewLoaded extends DetailedPeerReviewState {
  final DetailedPeerReviewModel detail;

  DetailedPeerReviewLoaded(this.detail);
}

class DetailedPeerReviewError extends DetailedPeerReviewState {
  final String message;

  DetailedPeerReviewError(this.message);
}
