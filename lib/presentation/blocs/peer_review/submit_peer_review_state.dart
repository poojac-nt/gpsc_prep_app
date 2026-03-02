import 'package:equatable/equatable.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_peer_review_model.dart';

abstract class SubmitPeerReviewState extends Equatable {
  const SubmitPeerReviewState();

  @override
  List<Object?> get props => [];
}

class SubmitPeerReviewInitial extends SubmitPeerReviewState {}

class SubmitPeerReviewLoading extends SubmitPeerReviewState {}

class SubmitPeerReviewSuccess extends SubmitPeerReviewState {
  final Comment comment;

  const SubmitPeerReviewSuccess(this.comment);

  @override
  List<Object?> get props => [comment];
}

class SubmitPeerReviewError extends SubmitPeerReviewState {
  final String message;

  const SubmitPeerReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
