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
    on<TimerStarted>(_onTimerRunning);
    on<TimerStopped>(_onTimerStop);
    on<TimerTicked>((event, emit) {
      emit(TimerRunning(event.remainingSeconds, event.remainingMinutes));
    });
  }
  Timer? timer;
  Future<void> _onTimerRunning(
    TimerStarted event,
    Emitter<TimerState> emit,
  ) async {
    timer?.cancel();
    int tickCount = 30 * 60;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      tickCount--;
      add(TimerTicked(tickCount % 60, tickCount ~/ 60));
      if (tickCount <= 0) {
        timer.cancel();
        add(TimerStopped());
      }
    });
  }

  Future<void> _onTimerStop(
    TimerStopped event,
    Emitter<TimerState> emit,
  ) async {
    timer?.cancel();
    emit(TimerCompleted(0, 0));
  }
}
