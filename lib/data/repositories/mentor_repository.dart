import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/mentor_assign_payload.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_assignment_list_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_dashbord_data.dart';
import 'package:gpsc_prep_app/domain/entities/pending_submission.dart';
import 'package:gpsc_prep_app/domain/entities/student_list_with_mentor.dart';

class MentorRepository {
  final SupabaseHelper _supabase;

  MentorRepository(this._supabase);

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
}
