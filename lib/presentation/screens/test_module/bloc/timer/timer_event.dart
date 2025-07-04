sealed class TimerEvent {}

class TimerInit extends TimerEvent {}

class TimerStarted extends TimerEvent {}

class TimerStopped extends TimerEvent {}

class TimerTicked extends TimerEvent {
  final int remainingSeconds;
  final int remainingMinutes;
  TimerTicked(this.remainingSeconds, this.remainingMinutes);
}
