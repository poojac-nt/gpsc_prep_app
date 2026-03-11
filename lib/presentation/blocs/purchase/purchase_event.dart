part of 'purchase_bloc.dart';

@immutable
sealed class PurchaseEvent {}

/// Fetch all courses purchased by the current user
class FetchPurchases extends PurchaseEvent {}

/// Purchase a new course
class PurchaseCourse extends PurchaseEvent {
  final UserPurchasePayload payload;
  PurchaseCourse(this.payload);
}
