part of 'mentor_evaluation_bloc.dart';

abstract class MentorEvaluationState {
  const MentorEvaluationState();
}

class MentorEvaluationInitial extends MentorEvaluationState {}

class MentorEvaluationLoading extends MentorEvaluationState {}

class MentorEvaluationLoaded extends MentorEvaluationState {
  final SubmissionReportModel data;

  const MentorEvaluationLoaded(this.data);
}

class MentorEvaluationError extends MentorEvaluationState {
  final String message;

  const MentorEvaluationError(this.message);
}

class MentorEvaluationSubmitting extends MentorEvaluationState {}

class MentorEvaluationSubmitSuccess extends MentorEvaluationState {}

class MentorEvaluationSubmitError extends MentorEvaluationState {
  final String message;

  const MentorEvaluationSubmitError(this.message);
}
