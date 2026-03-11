import 'package:gpsc_prep_app/domain/entities/detailed_peer_review_model.dart';

abstract class SubmitPeerReviewState {
  const SubmitPeerReviewState();
}

class SubmitPeerReviewInitial extends SubmitPeerReviewState {}

class SubmitPeerReviewLoading extends SubmitPeerReviewState {}

class SubmitPeerReviewSuccess extends SubmitPeerReviewState {
  final Comment comment;

  const SubmitPeerReviewSuccess(this.comment);
}

class SubmitPeerReviewError extends SubmitPeerReviewState {
  final String message;

  const SubmitPeerReviewError(this.message);
}
