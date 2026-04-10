import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
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
    _iapSubscription = _iapService.purchaseStream.listen(
      (updates) {
        for (final d in updates) {
          add(_OnIapPurchaseUpdate(d));
        }
      },
      onError: (Object e) => _log.e('PurchaseBloc: IAP stream error — $e'),
    );
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
      emit(IapPurchaseFailed(
        message: 'In-App Purchase is not available on this device.',
        purchases: currentPurchases,
      ));
      return;
    }

    // 2. Fetch the product from Play Store.
    final product = await _iapService.getProductDetails(event.productId);
    if (product == null) {
      emit(IapPurchaseFailed(
        message: 'Product not found. Please contact support.',
        purchases: currentPurchases,
      ));
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
      emit(IapPurchaseFailed(
        message: 'Failed to initiate purchase. Please try again.',
        purchases: currentPurchases,
      ));
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
        // Acknowledge the purchase on the platform side first.
        await _iapService.completePurchase(details);

        final payload = _pendingIapPayload;
        if (payload == null) {
          // Spurious callback (e.g. leftover from a previous session) — ignore.
          _log.w('IAP: purchased callback received with no pending payload.');
          return;
        }

        // 1. Enrich the payload with actual IAP details.
        payload.productId = details.productID;
        payload.purchaseToken = details.verificationData.serverVerificationData;

        // 2. Call the backend to verify the purchase.
        final result = await _repository.insertUserPurchase(payload: payload);

        result.fold(
          (failure) {
            _log.e('IAP: Backend verification failed: $failure');
            emit(IapPurchaseFailed(
              message:
                  'Verification failed. Please contact support.',
              purchases: currentPurchases,
            ));
          },
          (verifyResponse) {
            _pendingIapPayload = null;
            if (verifyResponse.isValid) {
              _log.i(
                'IAP: Verification success for course ${verifyResponse.courseId}',
              );
              // 1. Trigger a background refresh to get the full enrolment list.
              add(FetchPurchases());
              // 2. Emit success immediately so the UI can show the success state/message.
              emit(IapPurchaseSuccess(purchases: currentPurchases));
            } else {
              _log.e('IAP: Verification failed (isValid=false)');
              emit(IapPurchaseFailed(
                message:
                    'Purchase verification failed. Please contact support.',
                purchases: currentPurchases,
              ));
            }
          },
        );



      case PurchaseStatus.error:
        _log.e('IAP: Purchase error — ${details.error}');
        await _iapService.completePurchase(details);
        _pendingIapPayload = null;
        if (state is IapPurchasing || state is IapPurchaseFailed) {
          emit(IapPurchaseFailed(
            message:
                details.error?.message ?? 'Purchase failed. Please try again.',
            purchases: currentPurchases,
          ));
        }

      case PurchaseStatus.canceled:
        _log.i('IAP: Purchase cancelled by user');
        _pendingIapPayload = null;
        if (state is IapPurchasing) {
          emit(IapPurchaseFailed(
            message: 'Purchase was cancelled.',
            purchases: currentPurchases,
          ));
        }

      case PurchaseStatus.pending:
      case PurchaseStatus.restored:
        // No action needed for consumables.
        break;
    }
  }
}
