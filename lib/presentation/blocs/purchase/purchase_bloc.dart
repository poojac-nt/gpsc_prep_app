import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_purchase_payload.dart';
import 'package:gpsc_prep_app/data/repositories/purchase_repository.dart';
import 'package:gpsc_prep_app/domain/entities/user_purchase_model.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRepository _repository;
  final _log = getIt<LogHelper>();

  PurchaseBloc(this._repository) : super(PurchaseInitial()) {
    on<FetchPurchases>(_onFetchPurchases);
    on<PurchaseCourse>(_onPurchaseCourse);
  }

  Future<void> _onFetchPurchases(
    FetchPurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    final result = await _repository.fetchUserPurchasedCourses();
    result.fold(
      (failure) {
        _log.e('Failed to fetch purchases: $failure');
        emit(PurchaseFetchFailed(failure));
      },
      (purchases) {
        _log.i('Fetched ${purchases.length} purchases');
        emit(PurchaseFetched(purchases));
      },
    );
  }

  Future<void> _onPurchaseCourse(
    PurchaseCourse event,
    Emitter<PurchaseState> emit,
  ) async {
    // Keep current purchases visible while processing
    final currentPurchases = _currentPurchases();
    emit(PurchasePurchasing(currentPurchases));

    final result = await _repository.insertUserPurchase(payload: event.payload);
    result.fold(
      (failure) {
        _log.e('Failed to purchase course: $failure');
        emit(PurchaseFailed(failure: failure, purchases: currentPurchases));
      },
      (newPurchase) {
        final updated = [...currentPurchases, newPurchase];
        _log.i('Course purchased: ${newPurchase.courseId}');
        emit(PurchaseSuccess(updated));
      },
    );
  }

  List<UserPurchaseModel> _currentPurchases() {
    final s = state;
    if (s is PurchaseFetched) return s.purchases;
    if (s is PurchaseSuccess) return s.purchases;
    if (s is PurchaseFailed) return s.purchases;
    if (s is PurchasePurchasing) return s.purchases;
    return [];
  }
}
