import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';

import '../../core/error/failure.dart';
import '../../core/helpers/supabase_helper.dart';

class AuthRepository {
  final SupabaseHelper _supabase;

  AuthRepository(this._supabase);

  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async => await _supabase.login(email, password);

  Future<Either<Failure, UserModel>> createStudent(UserPayload data) async =>
      await _supabase.createStudent(data);

  Future<Either<Failure, MentorModel>> createMentor(UserPayload data) async =>
      await _supabase.createMentorByAdmin(data);

  Future<bool> doesUserExist(String email) async =>
      await _supabase.doesUserExist(email);

  Future<Either<Failure, UserModel>> updateUserInfo(UserPayload data) async =>
      await _supabase.updateUserInfo(data);

  Future<bool> deleteUser() async => await _supabase.deleteUser();

  Future<void> updateOrInsertFcmToken(String fcmToken) async =>
      await _supabase.updateOrInsertFcmToken(fcmToken);

  Future<void> requestResetPassword(String email) async =>
      await _supabase.requestResetPassword(email);

  Future<void> resetPassword(String password) async =>
      await _supabase.resetPassword(password);
}
