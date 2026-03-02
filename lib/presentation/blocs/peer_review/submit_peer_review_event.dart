import 'package:equatable/equatable.dart';

abstract class SubmitPeerReviewEvent extends Equatable {
  const SubmitPeerReviewEvent();

  @override
  List<Object?> get props => [];
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

  @override
  List<Object?> get props => [answerId, reviewerId, comment];
}
