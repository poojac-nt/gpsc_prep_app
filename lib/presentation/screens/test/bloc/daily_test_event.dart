import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';

sealed class DailyTestEvent {}

class DailyTestInit extends DailyTestEvent {}

class FetchDailyTest extends DailyTestEvent {}
