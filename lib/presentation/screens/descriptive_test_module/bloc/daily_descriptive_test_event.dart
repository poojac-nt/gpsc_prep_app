import 'package:flutter/cupertino.dart';

@immutable
sealed class DailyDescTestEvent {}

class DailyTestInit extends DailyDescTestEvent {}

class FetchAllTests extends DailyDescTestEvent {}
