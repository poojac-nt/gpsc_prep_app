part of 'peer_review_bloc.dart';

abstract class PeerReviewEvent {}

class FetchPeerReviews extends PeerReviewEvent {
  final int testId;
  final int questionId;

  FetchPeerReviews({required this.testId, required this.questionId});
}
