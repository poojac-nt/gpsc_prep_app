import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
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

  Future<Either<Failure, UserModel>> createUser(UserPayload data) async =>
      await _supabase.createUser(data);

  Future<bool> doesUserExist(String email) async =>
      await _supabase.doesUserExist(email);

  Future<Either<Failure, UserModel>> updateUserInfo(UserPayload data) async =>
      await _supabase.updateUserInfo(data);

  Future<void> deleteUser(String userId) async =>
      await _supabase.deleteUser(userId);

  Future<void> updateOrInsertFcmToken(String fcmToken) async =>
      await _supabase.updateOrInsertFcmToken(fcmToken);
}
