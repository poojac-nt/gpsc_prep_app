import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'package:gpsc_prep_app/domain/entities/submission_report_model.dart';

part 'mentor_evaluation_event.dart';
part 'mentor_evaluation_state.dart';

class MentorEvaluationBloc
    extends Bloc<MentorEvaluationEvent, MentorEvaluationState> {
  final MentorRepository _repository;

  MentorEvaluationBloc(this._repository) : super(MentorEvaluationInitial()) {
    on<FetchMentorEvaluationData>(_onFetchData);
    on<SubmitMentorEvaluation>(_onSubmitEvaluation);
  }

  Future<void> _onFetchData(
    FetchMentorEvaluationData event,
    Emitter<MentorEvaluationState> emit,
  ) async {
    emit(MentorEvaluationLoading());
    final result = await _repository.fetchSubmissionReport(event.submissionId);
    result.fold(
      (failure) => emit(MentorEvaluationError(failure.message)),
      (data) => emit(MentorEvaluationLoaded(data)),
    );
  }

  Future<void> _onSubmitEvaluation(
    SubmitMentorEvaluation event,
    Emitter<MentorEvaluationState> emit,
  ) async {
    emit(MentorEvaluationSubmitting());
    final result = await _repository.submitMentorEvaluation(
      submissionId: event.submissionId,
      mentorAssignmentId: event.mentorAssignmentId,
      questionScores: event.questionScores,
      feedback: event.feedback,
      evaluatedPdfFile: event.evaluatedPdfFile,
    );
    result.fold(
      (failure) => emit(MentorEvaluationSubmitError(failure.message)),
      (_) => emit(MentorEvaluationSubmitSuccess()),
    );
  }
}
