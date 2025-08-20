import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';

@immutable
sealed class DailyDescTestState {}

final class DailyTestInitial extends DailyDescTestState {}

final class DailyDescTestFetching extends DailyDescTestState {}

final class DailyDescTestFetched extends DailyDescTestState {
  final List<DescTestModel> dailyTestModel;

  DailyDescTestFetched(this.dailyTestModel);
}

final class DailyDescTestFetchFailed extends DailyDescTestState {
  final Failure failure;

  DailyDescTestFetchFailed(this.failure);
}

final class DescTestSubmit extends DailyDescTestState {}

final class DescTestSubmitFailed extends DailyDescTestState {
  final Failure failure;

  DescTestSubmitFailed(this.failure);
}

final class DescTestSubmitSuccess extends DailyDescTestState {
  final String message;

  DescTestSubmitSuccess(this.message);
}
