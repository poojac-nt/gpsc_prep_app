import 'package:equatable/equatable.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';

abstract class FreeTestReviewState extends Equatable {
  const FreeTestReviewState();

  @override
  List<Object> get props => [];
}

class FreeTestReviewInitial extends FreeTestReviewState {}

class FreeTestReviewLoading extends FreeTestReviewState {}

class FreeTestReviewLoaded extends FreeTestReviewState {
  final List<DescTestModel> submissions;
  final bool hasReachedMax;
  final int offset;
  final bool isFetchingMore;

  const FreeTestReviewLoaded(
    this.submissions, {
    this.hasReachedMax = false,
    this.offset = 0,
    this.isFetchingMore = false,
  });

  FreeTestReviewLoaded copyWith({
    List<DescTestModel>? submissions,
    bool? hasReachedMax,
    int? offset,
    bool? isFetchingMore,
  }) {
    return FreeTestReviewLoaded(
      submissions ?? this.submissions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      offset: offset ?? this.offset,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object> get props => [submissions, hasReachedMax, offset, isFetchingMore];
}

class FreeTestReviewError extends FreeTestReviewState {
  final String message;

  const FreeTestReviewError(this.message);

  @override
  List<Object> get props => [message];
}
