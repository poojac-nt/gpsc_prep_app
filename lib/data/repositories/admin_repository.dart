import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/admin_stats_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';

class AdminRepository {
  final SupabaseHelper _supabaseHelper;

  AdminRepository(this._supabaseHelper);

  Future<Either<Failure, AdminStatsModel>> getAdminStats() async {
    return await _supabaseHelper.fetchAdminStats();
  }

  Future<Either<Failure, List<MentorModel>>> getMentorList() async {
    return await _supabaseHelper.fetchMentorList();
  }

  Future<Either<Failure, UserModel>> updateMentor({
    required int userId,
    required String name,
    required String bio,
    required List<String> subjectExpertise,
    required bool isActive,
  }) async {
    return await _supabaseHelper.updateMentorInfo(
      userId: userId,
      name: name,
      bio: bio,
      subjectExpertise: subjectExpertise,
      isActive: isActive,
    );
  }

  Future<Either<Failure, void>> deleteMentor(int userId) async {
    return await _supabaseHelper.deleteMentorAccount(userId);
  }
}
