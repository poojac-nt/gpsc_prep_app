import 'package:flutter/foundation.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_purchase_payload.dart';

@immutable
sealed class PurchaseEvent {}

/// Fetch all courses purchased by the current user
class FetchPurchases extends PurchaseEvent {}

/// Purchase a new course
class PurchaseCourse extends PurchaseEvent {
  final UserPurchasePayload payload;
  PurchaseCourse(this.payload);
}
