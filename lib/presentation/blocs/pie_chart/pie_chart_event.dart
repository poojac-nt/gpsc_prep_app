import 'package:flutter/cupertino.dart';

@immutable
sealed class PieChartEvent {}

class FetchCorrectnessCountsEvent extends PieChartEvent {
  final int testId;

  FetchCorrectnessCountsEvent({required this.testId});
}
