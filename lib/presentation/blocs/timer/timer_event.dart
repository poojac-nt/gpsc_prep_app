sealed class TimerEvent {}

class TimerInit extends TimerEvent {}

class TimerStart extends TimerEvent {
  final int? testDuration;
  TimerStart({this.testDuration});
}

class TimerStop extends TimerEvent {
  final bool isManual;
  TimerStop({this.isManual = true});
}

class TimerReset extends TimerEvent {}

class TimerTicked extends TimerEvent {
  final int remainingSeconds;
  final int remainingMinutes;
  TimerTicked(this.remainingSeconds, this.remainingMinutes);
}
