import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'log_helper.dart';

class SupabaseHelper {
  final _supabase = Supabase.instance.client;
  final LogHelper _log;

  SupabaseHelper(this._log);

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

  Future<Either<Failure, UserModel>> createUser(UserPayload data) async {
    try {
      final jsonData = data.toJson();
      _log.d('[insertUser] Payload: $jsonData');
      final existingUser =
          await _supabase
              .from(SupabaseKeys.users)
              .select('user_email')
              .eq('user_email', data.email)
              .maybeSingle();

      if (existingUser != null) {
        _log.w('Email already exists: ${data.email}');
        return Left(Failure('A user with this email already exists.'));
      }

      final signUpResponse = await _supabase.auth.signUp(
        password: data.password!,
        email: data.email,
      );
      final user = signUpResponse.user;

      if (user == null) {
        _log.e('User SignUp Failed');
      }
      final userId = user?.id;
      _log.d("User id: $userId");
      final insertResponse =
          await _supabase
              .from(SupabaseKeys.users)
              .insert({
                'full_name': data.name,
                'address': data.address,
                'number': data.number,
                'role': 'Student',
                'user_email': data.email,
                'auth_id': userId,
                'profile_picture': data.profilePicture,
              })
              .select('*')
              .single();
      _log.i('[UserCreated] Response: $insertResponse');
      final userModel = UserModel.fromJson(insertResponse);
      return Right(userModel);
    } catch (e) {
      return Left(Failure('Error Creating New User $e'));
    }
  }
}
