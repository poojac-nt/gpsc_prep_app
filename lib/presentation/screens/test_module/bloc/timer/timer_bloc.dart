import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc() : super(TimerInitial()) {
    on<TimerInit>((event, emit) {
      timer?.cancel();
      emit(TimerInitial());
    });
    on<TimerStart>(_onTimerStarted);
    on<TimerStop>(_onTimerStop);
    on<TimerReset>(_onTimerReset);
    on<TimerTicked>(_onTimerTicked);
  }
  Timer? timer;
  bool _hasTestBeenSubmitted = false;
  bool get hasTestBeenSubmitted => _hasTestBeenSubmitted;

  int tickCount = 0;
  Future<void> _onTimerStarted(
    TimerStart event,
    Emitter<TimerState> emit,
  ) async {
    timer?.cancel();
    tickCount = 30 * 60;
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      tickCount--;
      add(TimerTicked(tickCount % 60, tickCount ~/ 60));
      if (tickCount <= 0) {
        timer?.cancel();
        add(TimerStop(isManual: false));
      }
    });
  }

  Future<void> _onTimerTicked(
    TimerTicked event,
    Emitter<TimerState> emit,
  ) async {
    emit(TimerRunning(event.remainingSeconds, event.remainingMinutes));
  }

  Future<void> _onTimerReset(TimerReset event, Emitter<TimerState> emit) async {
    timer?.cancel();
    _hasTestBeenSubmitted = false;
    emit(TimerInitial());
  }

  Future<void> _onTimerStop(TimerStop event, Emitter<TimerState> emit) async {
    timer?.cancel();
    int timeSpent = 0;
    _hasTestBeenSubmitted = true;

    if (event.isManual) {
      if (state is TimerStopped) {
        // Already stopped: don’t override with 0
        emit(state); // return same state
        return;
      }

      int spentMins = 0;
      int spentSecs = 0;

      if (state is TimerRunning) {
        final current = state as TimerRunning;
        final remaining =
            current.remainingMinutes * 60 + current.remainingSeconds;
        final timeSpent = 30 * 60 - remaining;

        spentMins = timeSpent ~/ 60;
        spentSecs = timeSpent % 60;
      }

      emit(TimerStopped(spentMins, spentSecs, event.isManual));
      // if (state is TimerRunning) {
      //   final currentState = state as TimerRunning;
      //   var remainingTime =
      //       currentState.remainingMinutes * 60 + currentState.remainingSeconds;
      //   timeSpent = 30 * 60 - remainingTime;
      //   print("timeSpent :$timeSpent");
      //   var spentMins = timeSpent ~/ 60;
      //   var spentSecs = timeSpent % 60;
      //   emit(TimerStopped(spentMins, spentSecs, event.isManual));
      // } else {
      //   // If not running, fall back safely
      //   emit(TimerStopped(0, 0, event.isManual));
      // }
    } else {
      emit(TimerStopped(30, 0, false));
    }
  }
}
