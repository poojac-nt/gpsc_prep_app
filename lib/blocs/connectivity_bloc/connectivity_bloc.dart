import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:meta/meta.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final _log = getIt<LogHelper>();
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      add(CheckConnectivity());
    }, onError: (e) => _log.e("Connectivity stream error: $e"));
    on<ResetConnectivity>((event, emit) {
      emit(ConnectivityInitial());
    });
    add(CheckConnectivity());
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<ConnectivityState> emit,
  ) async {
    final result = await _connectivity.checkConnectivity();

    final hasNetwork =
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);

    if (hasNetwork) {
      final hasInternet = await _hasInternetAccess();
      if (hasInternet) {
        _log.i("✅ Connectivity: Network + Internet available");
        emit(ConnectivityOnline());
      } else {
        _log.w("⚠️ Network connected, but no internet");
        emit(ConnectivityOffline());
      }
    } else {
      _log.w("❌ No network connection at all");
      emit(ConnectivityOffline());
    }
  }

  // Utility method to check real internet
  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
