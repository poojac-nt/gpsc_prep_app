import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class MentorEvaluationEvent extends Equatable {
  const MentorEvaluationEvent();

  @override
  List<Object?> get props => [];
}

class FetchMentorEvaluationData extends MentorEvaluationEvent {
  final int submissionId;

  const FetchMentorEvaluationData(this.submissionId);

  @override
  List<Object?> get props => [submissionId];
}

class SubmitMentorEvaluation extends MentorEvaluationEvent {
  final int submissionId;
  final int mentorAssignmentId;
  final Map<String, dynamic> questionScores;
  final String? feedback;
  final File? evaluatedPdfFile;

  const SubmitMentorEvaluation({
    required this.submissionId,
    required this.mentorAssignmentId,
    required this.questionScores,
    this.feedback,
    this.evaluatedPdfFile,
  });

  @override
  List<Object?> get props => [
    submissionId,
    questionScores,
    feedback,
    evaluatedPdfFile,
  ];
}
