import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/mentor_assign_payload.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_assignment_list_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_dashbord_data.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_test_submissions.dart';
import 'package:gpsc_prep_app/domain/entities/pending_submission.dart';
import 'package:gpsc_prep_app/domain/entities/student_list_with_mentor.dart';
import 'package:gpsc_prep_app/domain/entities/subject_model.dart';
import 'package:gpsc_prep_app/domain/entities/submission_report_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_free_test_list_model.dart';

class MentorRepository {
  final SupabaseHelper _supabase;

  MentorRepository(this._supabase);

  Future<Either<Failure, List<MentorModel>>> getMentorList() async {
    return await _supabase.fetchMentorList();
  }

  Future<Either<Failure, MentorModel>> getMentorByUserId(int userId) async {
    return await _supabase.fetchMentorByUserId(userId);
  }

  Future<Either<Failure, MentorModel>> updateMentor({
    required int userId,
    required String name,
    required String bio,
    required List<String> subjectExpertise,
    required bool isActive,
    File? profileImage,
  }) async {
    return await _supabase.updateMentorInfo(
      userId: userId,
      name: name,
      bio: bio,
      subjectExpertise: subjectExpertise,
      isActive: isActive,
      profileImage: profileImage,
    );
  }

  Future<Either<Failure, List<SubjectModel>>> fetchSubjects() async {
    return await _supabase.fetchSubjects();
  }

  Future<Either<Failure, List<PendingSubmission>>>
  fetchPendingSubmissions() async => await _supabase.fetchPendingSubmission();

  Future<Either<Failure, List<StudentListWithMentor>>>
  fetchTestWisePendingSubmission({required int testId}) async =>
      await _supabase.fetchTestWisePendingSubmission(testId: testId);

  Future<Either<Failure, void>> assignMentorToTest({
    required List<MentorAssignmentPayload> payloads,
  }) async => await _supabase.assignMentorToTest(payloads: payloads);

  Future<Either<Failure, MentorDashboardData>>
  fetchMentorDashboardData() async =>
      await _supabase.fetchMentorDashboardData();

  Future<Either<Failure, List<MentorAssignmentListModel>>>
  fetchMentorSubmission() async => await _supabase.fetchMentorSubmission();

  Future<Either<Failure, List<MentorTestSubmissions>>>
  fetchMentorTestSubmission({required int testId}) async =>
      await _supabase.fetchMentorTestSubmission(testId: testId);

  Future<Either<Failure, SubmissionReportModel>> fetchSubmissionReport(
    int submissionId,
  ) async => await _supabase.fetchSubmissionReport(submissionId: submissionId);

  Future<Either<Failure, void>> submitMentorEvaluation({
    required int submissionId,
    required int mentorAssignmentId,
    required Map<String, dynamic> questionScores,
    String? feedback,
    File? evaluatedPdfFile,
  }) async => await _supabase.submitMentorEvaluation(
    submissionId: submissionId,
    mentorAssignmentId: mentorAssignmentId,
    questionScores: questionScores,
    feedback: feedback,
    evaluatedPdfFile: evaluatedPdfFile,
  );

  Future<Either<Failure, List<DescFreeTestWithUsers>>>
  fetchSubmittedFreeDescTests() async =>
      await _supabase.fetchSubmittedFreeDescTests();
}
