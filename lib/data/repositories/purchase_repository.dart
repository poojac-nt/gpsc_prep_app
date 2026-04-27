import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_purchase_payload.dart';
import 'package:gpsc_prep_app/domain/entities/user_purchase_model.dart';

import '../../core/error/failure.dart';
import '../models/payloads/verify_purchase_response.dart';

class PurchaseRepository {
  final SupabaseHelper _supabase;

  PurchaseRepository(this._supabase);

  Future<Either<Failure, VerifyPurchaseResponse>> insertUserPurchase({
    required UserPurchasePayload payload,
  }) async => await _supabase.verifyPurchase(payload: payload);

  Future<Either<Failure, List<UserPurchaseModel>>>
  fetchUserPurchasedCourses() async => await _supabase.fetchUserPurchase();

  Future<Either<Failure, UserPurchaseModel>> freePurchase({
    required UserPurchasePayload payload,
  }) async => await _supabase.freePurchase(payload: payload);
}
