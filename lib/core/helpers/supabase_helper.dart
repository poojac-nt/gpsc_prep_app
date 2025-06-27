import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'log_helper.dart';

class SupabaseHelper {
  final _supabase = Supabase.instance.client;
  final LogHelper _log;

  SupabaseHelper(this._log);

  Future<bool> doesUserEmailExist(String email) async {
    final response = await _supabase
        .from(SupabaseKeys.users)
        .select()
        .eq(SupabaseKeys.email, email);
    if (response.isEmpty) {
      return true;
    }
    return false;
  }

  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _log.i('[login] Auth response: $response');
      final userId = response.user?.id;
      if (userId == null) {
        return Left(Failure('User ID not found after login.'));
      }

      final userResponse =
          await _supabase
              .from(SupabaseKeys.users)
              .select()
              .eq(SupabaseKeys.authId, userId)
              .single();
      _log.i('[login] User table response: $userResponse');
      final user = UserModel.fromJson(userResponse);
      return Right(user);
    } catch (e, s) {
      _log.e('[login] Error occurred', error: e, s: s);
      return Left(Failure('Incorrect Username or Password.'));
    }
  }
}
