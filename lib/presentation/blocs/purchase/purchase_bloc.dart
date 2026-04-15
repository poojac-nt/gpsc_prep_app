import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_purchase_payload.dart';
import 'package:gpsc_prep_app/data/repositories/purchase_repository.dart';
import 'package:gpsc_prep_app/domain/entities/user_purchase_model.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/services/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRepository _repository;
  final IapService _iapService;
  final _log = getIt<LogHelper>();

  /// Payload to forward to the backend after a successful IAP acknowledgement.
  UserPurchasePayload? _pendingIapPayload;

  late final StreamSubscription<List<PurchaseDetails>> _iapSubscription;

  PurchaseBloc(this._repository, this._iapService) : super(PurchaseInitial()) {
    on<FetchPurchases>(_onFetchPurchases);
    on<PurchaseCourse>(_onPurchaseCourse);
    on<InitiateIapPurchase>(_onInitiateIapPurchase);
    on<_OnIapPurchaseUpdate>(_onIapPurchaseUpdate);

    // Subscribe to the IAP purchase stream for the lifetime of this bloc.
    // Each update is forwarded as an internal event so it goes through
    // the standard BLoC event queue (thread-safe, testable).
    _iapSubscription = _iapService.purchaseStream.listen((updates) {
      for (final d in updates) {
        add(_OnIapPurchaseUpdate(d));
      }
    }, onError: (Object e) => _log.e('PurchaseBloc: IAP stream error — $e'));
  }

  @override
  Future<void> close() async {
    await _iapSubscription.cancel();
    return super.close();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Existing handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onFetchPurchases(
    FetchPurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading(purchases: state.purchases));
    final result = await _repository.fetchUserPurchasedCourses();
    result.fold(
      (failure) {
        _log.e('Failed to fetch purchases: $failure');
        emit(PurchaseFetchFailed(failure: failure, purchases: state.purchases));
      },
      (purchases) {
        _log.i('Fetched ${purchases.length} purchases');
        emit(PurchaseFetched(purchases: purchases));
      },
    );
  }

  Future<void> _onPurchaseCourse(
    PurchaseCourse event,
    Emitter<PurchaseState> emit,
  ) async {
    final currentPurchases = state.purchases;
    emit(PurchasePurchasing(purchases: currentPurchases));

    final result = await _repository.insertUserPurchase(payload: event.payload);
    result.fold(
      (failure) {
        _log.e('Failed to purchase course: $failure');
        emit(PurchaseFailed(failure: failure, purchases: currentPurchases));
      },
      (verifyResponse) {
        _log.i('Course purchased/verified: ${verifyResponse.courseId}');
        if (verifyResponse.isValid) {
          // Trigger a background refresh to get the full enrolment list.
          add(FetchPurchases());
          emit(PurchaseSuccess(purchases: currentPurchases));
        } else {
          emit(
            PurchaseFailed(
              failure: Failure('Purchase verification failed.'),
              purchases: currentPurchases,
            ),
          );
        }
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IAP handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onInitiateIapPurchase(
    InitiateIapPurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    final currentPurchases = state.purchases;
    emit(IapPurchasing(purchases: currentPurchases));

    // 1. Verify Play Store is reachable.
    final available = await _iapService.isAvailable();
    if (!available) {
      _log.e('IapService is not available on this device');
      emit(
        IapPurchaseFailed(
          message: 'In-App Purchase is not available on this device.',
          purchases: currentPurchases,
        ),
      );
      return;
    }

    // 2. Fetch the product from Play Store.
    final product = await _iapService.getProductDetails(event.productId);
    if (product == null) {
      emit(
        IapPurchaseFailed(
          message: 'Product not found. Please contact support.',
          purchases: currentPurchases,
        ),
      );
      return;
    }

    // 3. Store payload — consumed by _onIapPurchaseUpdate on success.
    _pendingIapPayload = event.backendPayload;

    // 4. Launch the Play Store payment sheet.
    try {
      await _iapService.buyConsumable(product);
      // From here _onIapPurchaseUpdate handles the result asynchronously.
    } catch (e) {
      _log.e('buyConsumable threw: $e');
      _pendingIapPayload = null;
      emit(
        IapPurchaseFailed(
          message: 'Failed to initiate purchase. Please try again.',
          purchases: currentPurchases,
        ),
      );
    }
  }

  Future<void> _onIapPurchaseUpdate(
    _OnIapPurchaseUpdate event,
    Emitter<PurchaseState> emit,
  ) async {
    final details = event.details;
    final currentPurchases = state.purchases;

    switch (details.status) {
      case PurchaseStatus.purchased:
        _log.i('IAP: PURCHASE DETECTED');

        final payload = _pendingIapPayload;
        if (payload == null) {
          _log.w('IAP: purchased callback with NULL payload');
          return;
        }

        try {
          // 1️⃣ Attach purchase data
          payload.productId = details.productID;
          payload.purchaseToken =
              details.verificationData.serverVerificationData;

          _log.i('IAP: CALLING BACKEND');

          // 2️⃣ Call backend
          final result = await _repository.insertUserPurchase(payload: payload);

          await result.fold(
            (failure) async {
              _log.e('IAP: Backend verification failed: $failure');

              emit(
                IapPurchaseFailed(
                  message:
                      'Verification failed. Please contact support.$failure',
                  purchases: currentPurchases,
                ),
              );
            },
            (verifyResponse) async {
              _pendingIapPayload = null;

              if (verifyResponse.isValid) {
                _log.i(
                  'IAP: Verification SUCCESS for course ${verifyResponse.courseId}',
                );

                // Refresh purchases
                add(FetchPurchases());

                emit(IapPurchaseSuccess(purchases: currentPurchases));
              } else {
                _log.e('IAP: Verification FAILED (isValid=false)');

                emit(
                  IapPurchaseFailed(
                    message: 'Purchase verification failed.',
                    purchases: currentPurchases,
                  ),
                );
              }
            },
          );
        } catch (e) {
          _log.e('IAP: Exception during verification: $e');

          emit(
            IapPurchaseFailed(
              message: 'Something went wrong during verification.',
              purchases: currentPurchases,
            ),
          );
        }

        // 3️⃣ COMPLETE PURCHASE (AFTER EVERYTHING)
        if (details.pendingCompletePurchase) {
          _log.i('IAP: Completing purchase');
          await _iapService.completePurchase(details);
        }

        break;

      case PurchaseStatus.error:
        _log.e('IAP: Purchase error — ${details.error}');

        _pendingIapPayload = null;

        emit(
          IapPurchaseFailed(
            message:
                details.error?.message ?? 'Purchase failed. Please try again.',
            purchases: currentPurchases,
          ),
        );

        if (details.pendingCompletePurchase) {
          await _iapService.completePurchase(details);
        }

        break;

      case PurchaseStatus.canceled:
        _log.i('IAP: Purchase cancelled by user');

        _pendingIapPayload = null;

        emit(
          IapPurchaseFailed(
            message: 'Purchase was cancelled.',
            purchases: currentPurchases,
          ),
        );

        break;

      case PurchaseStatus.pending:
        _log.i('IAP: Purchase pending...');
        break;

      case PurchaseStatus.restored:
        _log.i('IAP: Purchase restored');

        // Optional: you can verify restored purchases as well
        // For now, just log
        break;
    }
  }
}
