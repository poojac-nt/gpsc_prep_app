import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/timer/timer_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/timer/timer_state.dart';

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
  int testDuration = 0;

  Future<void> _onTimerStarted(
    TimerStart event,
    Emitter<TimerState> emit,
  ) async {
    timer?.cancel();
    testDuration = event.testDuration!;
    tickCount = event.testDuration! * 60;

    emit(TimerRunning(tickCount % 60, tickCount ~/ 60));
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

    _hasTestBeenSubmitted = true;
    int spentMins = 0;
    int spentSecs = 0;
    if (state is TimerRunning) {
      final current = state as TimerRunning;
      final remaining =
          current.remainingMinutes * 60 + current.remainingSeconds;
      final timeSpent = testDuration * 60 - remaining;
      spentMins = timeSpent ~/ 60;
      spentSecs = timeSpent % 60;
    } else if (state is TimerStopped) {
      emit(state);
      return;
    }
    emit(TimerStopped(spentMins, spentSecs, event.isManual));
  }
}
