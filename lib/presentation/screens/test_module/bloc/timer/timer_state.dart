sealed class TimerState {}

class TimerInitial extends TimerState {}

class TimerRunning extends TimerState {
  final int remainingSeconds;
  final int remainingMinutes;
  TimerRunning(this.remainingSeconds, this.remainingMinutes);
}

class TimerStopped extends TimerState {
  final int totalMins;
  final int totalSecs;
  final bool isManual;

  TimerStopped(this.totalMins, this.totalSecs, this.isManual);
}
