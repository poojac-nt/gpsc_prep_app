import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';

import '../../core/error/failure.dart';
import '../../core/helpers/supabase_helper.dart';

class AuthenticationRepository {
  final SupabaseHelper _supabase;

  AuthenticationRepository(this._supabase);

  Future<bool> doesUsernameExist(String email) async =>
      await _supabase.doesUserEmailExist(email);

  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async => await _supabase.login(email, password);
}
