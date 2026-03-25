part of 'detailed_peer_review_bloc.dart';

abstract class DetailedPeerReviewEvent {}

class FetchDetailedPeerReview extends DetailedPeerReviewEvent {
  final int answerId;

  FetchDetailedPeerReview({required this.answerId});
}
