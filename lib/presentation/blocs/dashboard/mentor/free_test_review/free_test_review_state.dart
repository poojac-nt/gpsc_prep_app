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

  const FreeTestReviewLoaded(this.submissions);

  @override
  List<Object> get props => [submissions];
}

class FreeTestReviewError extends FreeTestReviewState {
  final String message;

  const FreeTestReviewError(this.message);

  @override
  List<Object> get props => [message];
}
