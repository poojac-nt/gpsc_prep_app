import 'dart:io';

import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Android-only service for consumable in-app purchases.
///
/// Register as a lazy singleton in GetIt and inject into [PurchaseBloc].
/// The bloc subscribes to [purchaseStream] for the lifetime of the app and
/// dispatches internal events for each [PurchaseDetails] update.
class IapService {
  IapService(this._log);

  final LogHelper _log;
  final InAppPurchase _iap = InAppPurchase.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // Stream
  // ─────────────────────────────────────────────────────────────────────────

  /// Raw purchase-update stream forwarded from the platform plugin.
  /// Subscribe once in [PurchaseBloc] and cancel in [close()].
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  // ─────────────────────────────────────────────────────────────────────────
  // Availability
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns `true` only when running on Android and the Play Store is
  /// reachable. Always returns `false` on iOS (not supported in this build).
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) {
      _log.w('IapService: IAP is Android-only in this build.');
      return false;
    }
    return _iap.isAvailable();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Product lookup
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetches the [ProductDetails] for [productId] from the Play Store.
  ///
  /// Returns `null` if the product cannot be found or an error occurs.
  Future<ProductDetails?> getProductDetails(String productId) async {
    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.error != null) {
        _log.e(
          'IapService: queryProductDetails error for "$productId" — ${response.error}',
        );
        return null;
      }
      if (response.productDetails.isEmpty) {
        _log.e(
          'IapService: No product found for id "$productId". '
          'Verify it is published in Play Console.',
        );
        return null;
      }
      return response.productDetails.first;
    } catch (e, st) {
      _log.e('IapService: getProductDetails threw — $e\n$st');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Purchase
  // ─────────────────────────────────────────────────────────────────────────

  /// Launches the Play Store payment sheet for a consumable [product].
  Future<void> buyConsumable(ProductDetails product) async {
    if (!Platform.isAndroid) return;
    final param = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: param);
  }

  /// Acknowledges/completes [details] on the platform side.
  ///
  /// Must be called for every [PurchaseDetails] that has
  /// [PurchaseDetails.pendingCompletePurchase] == `true`.
  Future<void> completePurchase(PurchaseDetails details) async {
    if (details.pendingCompletePurchase) {
      await _iap.completePurchase(details);
    }
  }
}
