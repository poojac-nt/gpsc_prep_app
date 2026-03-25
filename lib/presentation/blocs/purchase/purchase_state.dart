part of 'purchase_bloc.dart';

@immutable
sealed class PurchaseState {}

/// Initial / idle state
final class PurchaseInitial extends PurchaseState {}

/// Fetching purchases
final class PurchaseLoading extends PurchaseState {}

/// Purchases fetched successfully
final class PurchaseFetched extends PurchaseState {
  final List<UserPurchaseModel> purchases;
  PurchaseFetched(this.purchases);

  bool isCourseEnrolled(int courseId) =>
      purchases.any((p) => p.courseId == courseId);
}

/// Failed to fetch purchases
final class PurchaseFetchFailed extends PurchaseState {
  final Failure failure;
  PurchaseFetchFailed(this.failure);
}

/// Currently purchasing a course
final class PurchasePurchasing extends PurchaseState {
  final List<UserPurchaseModel> purchases;
  PurchasePurchasing(this.purchases);
}

/// Course purchased successfully
final class PurchaseSuccess extends PurchaseState {
  final List<UserPurchaseModel> purchases;
  PurchaseSuccess(this.purchases);

  bool isCourseEnrolled(int courseId) =>
      purchases.any((p) => p.courseId == courseId);
}

/// Failed to purchase
final class PurchaseFailed extends PurchaseState {
  final Failure failure;
  final List<UserPurchaseModel> purchases;
  PurchaseFailed({required this.failure, required this.purchases});
}
