import 'dart:io';

abstract class MentorEvaluationEvent {
  const MentorEvaluationEvent();
}

class FetchMentorEvaluationData extends MentorEvaluationEvent {
  final int submissionId;

  const FetchMentorEvaluationData(this.submissionId);
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
}
