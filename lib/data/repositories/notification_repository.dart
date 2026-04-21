import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/all_tests_model.dart';
import 'package:gpsc_prep_app/domain/entities/notification_model.dart';

class NotificationRepository {
  final SupabaseHelper _supabase;

  NotificationRepository(this._supabase);

  Future<Either<Failure, NotificationModel>> createNotification(
    NotificationModel notification,
  ) async {
    return await _supabase.createNotification(notification);
  }

  Future<Either<Failure, AllTestsModel>> getNotificationMetadata() async {
    return await _supabase.fetchNotificationMetadata();
  }
}
