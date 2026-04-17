part of 'purchase_bloc.dart';

@immutable
sealed class PurchaseState {
  /// The list of courses currently enrolled by the user.
  /// Carried across all states to prevent UI flickering during refreshes.
  final List<UserPurchaseModel> purchases;

  const PurchaseState({required this.purchases});

  bool isCourseEnrolled(int courseId) =>
      purchases.any((p) => p.courseId == courseId && p.isActive);

  /// Check if a specific test within a course is accessible.
  /// A test is accessible if the user is enrolled in the full course
  /// OR if any individual purchase for the course includes this testId.
  bool isTestAccessible(int courseId, int testId) {
    return purchases
        .any((p) => p.courseId == courseId && p.isTestUnlocked(testId));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// General Flows
// ─────────────────────────────────────────────────────────────────────────────

/// Initial / idle state.
final class PurchaseInitial extends PurchaseState {
  const PurchaseInitial() : super(purchases: const []);
}

/// Fetching purchases from the backend.
final class PurchaseLoading extends PurchaseState {
  const PurchaseLoading({required super.purchases});
}

/// Purchases fetched successfully.
final class PurchaseFetched extends PurchaseState {
  const PurchaseFetched({required super.purchases});
}

/// Failed to fetch purchases.
final class PurchaseFetchFailed extends PurchaseState {
  final Failure failure;
  const PurchaseFetchFailed({required this.failure, required super.purchases});
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy Purchase Flows
// ─────────────────────────────────────────────────────────────────────────────

/// Currently purchasing a course (legacy backend-only flow).
final class PurchasePurchasing extends PurchaseState {
  const PurchasePurchasing({required super.purchases});
}

/// Course purchased successfully (legacy backend-only flow).
final class PurchaseSuccess extends PurchaseState {
  const PurchaseSuccess({required super.purchases});
}

/// Failed to purchase (legacy backend-only flow).
final class PurchaseFailed extends PurchaseState {
  final Failure failure;
  const PurchaseFailed({required this.failure, required super.purchases});
}

// ─────────────────────────────────────────────────────────────────────────────
// IAP Purchase Flows
// ─────────────────────────────────────────────────────────────────────────────

/// The native Play Store payment sheet has been launched; awaiting user action.
final class IapPurchasing extends PurchaseState {
  const IapPurchasing({required super.purchases});
}

/// IAP payment succeeded and the backend enrolment record was created.
final class IapPurchaseSuccess extends PurchaseState {
  const IapPurchaseSuccess({required super.purchases});
}

/// IAP payment failed, was cancelled, or the backend insert failed.
final class IapPurchaseFailed extends PurchaseState {
  final String message;
  const IapPurchaseFailed({required this.message, required super.purchases});
}
