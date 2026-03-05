import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_purchase_payload.dart';
import 'package:gpsc_prep_app/domain/entities/user_purchase_model.dart';

import '../../core/error/failure.dart';

class PurchaseRepository {
  final SupabaseHelper _supabase;

  PurchaseRepository(this._supabase);

  Future<Either<Failure, UserPurchaseModel>> insertUserPurchase({
    required UserPurchasePayload payload,
  }) async => await _supabase.purchaseCourse(payload: payload);

  Future<Either<Failure, List<UserPurchaseModel>>>
  fetchUserPurchasedCourses() async => await _supabase.fetchUserPurchase();
}
