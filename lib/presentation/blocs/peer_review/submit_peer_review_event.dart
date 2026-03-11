part of 'submit_peer_review_bloc.dart';

abstract class SubmitPeerReviewEvent {
  const SubmitPeerReviewEvent();
}

class SubmitPeerReview extends SubmitPeerReviewEvent {
  final int answerId;
  final int reviewerId;
  final String comment;

  const SubmitPeerReview({
    required this.answerId,
    required this.reviewerId,
    required this.comment,
  });
}

class ResetSubmitPeerReviewState extends SubmitPeerReviewEvent {}
