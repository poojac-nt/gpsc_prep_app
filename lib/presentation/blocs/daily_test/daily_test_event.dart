import 'package:flutter/cupertino.dart';

@immutable
sealed class DailyTestEvent {}

class DailyTestInit extends DailyTestEvent {}

class FetchTests extends DailyTestEvent {}
