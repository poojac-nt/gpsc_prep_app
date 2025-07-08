import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';

sealed class DailyTestState {}

class DailyTestInitial extends DailyTestState {}

class DailyTestFetching extends DailyTestState {}

class DailyTestFetched extends DailyTestState {
  final List<DailyTestModel> dailyTestModel;
  DailyTestFetched(this.dailyTestModel);
}

class DailyTestFetchFailed extends DailyTestState {
  final Failure failure;
  DailyTestFetchFailed(this.failure);
}
