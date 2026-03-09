import 'package:equatable/equatable.dart';
import 'package:gpsc_prep_app/domain/entities/submission_report_model.dart';

abstract class MentorEvaluationState extends Equatable {
  const MentorEvaluationState();

  @override
  List<Object?> get props => [];
}

class MentorEvaluationInitial extends MentorEvaluationState {}

class MentorEvaluationLoading extends MentorEvaluationState {}

class MentorEvaluationLoaded extends MentorEvaluationState {
  final SubmissionReportModel data;

  const MentorEvaluationLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class MentorEvaluationError extends MentorEvaluationState {
  final String message;

  const MentorEvaluationError(this.message);

  @override
  List<Object?> get props => [message];
}

class MentorEvaluationSubmitting extends MentorEvaluationState {}

class MentorEvaluationSubmitSuccess extends MentorEvaluationState {}

class MentorEvaluationSubmitError extends MentorEvaluationState {
  final String message;

  const MentorEvaluationSubmitError(this.message);

  @override
  List<Object?> get props => [message];
}
