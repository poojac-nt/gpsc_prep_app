sealed class TimerState {}

class TimerInitial extends TimerState {}

class TimerRunning extends TimerState {
  final int remainingSeconds;
  final int remainingMinutes;
  TimerRunning(this.remainingSeconds, this.remainingMinutes);
}

class TimerCompleted extends TimerState {
  final int totalMins;
  final int totalSecs;

  TimerCompleted(this.totalMins, this.totalSecs);
}
