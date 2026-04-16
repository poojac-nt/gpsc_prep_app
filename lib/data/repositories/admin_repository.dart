import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/admin_stats_model.dart';

import 'package:gpsc_prep_app/data/models/payloads/product_payload.dart';
import '../../domain/entities/product_model.dart';

class AdminRepository {
  final SupabaseHelper _supabaseHelper;

  AdminRepository(this._supabaseHelper);

  Future<Either<Failure, AdminStatsModel>> getAdminStats() async {
    return await _supabaseHelper.fetchAdminStats();
  }

  Future<Either<Failure, ProductModel>> createProduct(
    ProductPayload payload,
  ) async {
    return await _supabaseHelper.createProduct(payload);
  }
}
