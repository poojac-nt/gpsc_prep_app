import 'package:equatable/equatable.dart';

abstract class FreeTestReviewEvent extends Equatable {
  const FreeTestReviewEvent();

  @override
  List<Object> get props => [];
}

class FetchFreeTestReviews extends FreeTestReviewEvent {}

class LoadMoreFreeTestReviews extends FreeTestReviewEvent {}
