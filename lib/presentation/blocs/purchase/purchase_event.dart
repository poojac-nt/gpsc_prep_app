part of 'purchase_bloc.dart';

@immutable
sealed class PurchaseEvent {}

/// Fetch all courses purchased by the current user.
class FetchPurchases extends PurchaseEvent {}

/// Purchase a new course via the legacy (no-IAP) backend-only flow.
class PurchaseCourse extends PurchaseEvent {
  final UserPurchasePayload payload;
  PurchaseCourse(this.payload);
}

/// Trigger the native Play Store payment sheet for a consumable product.
///
/// [productId] must match a product ID in [IapProductIds].
/// [backendPayload] will be sent to Supabase once the payment is confirmed.
class InitiateIapPurchase extends PurchaseEvent {
  final String productId;
  final UserPurchasePayload backendPayload;
  InitiateIapPurchase({required this.productId, required this.backendPayload});
}

/// Internal event — dispatched by the IAP stream listener inside the bloc.
/// Not intended for external use.
class _OnIapPurchaseUpdate extends PurchaseEvent {
  final PurchaseDetails details;
  _OnIapPurchaseUpdate(this.details);
}
