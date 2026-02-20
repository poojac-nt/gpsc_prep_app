import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/test_model.dart';

@immutable
sealed class FetchSingleTestState {}

final class FetchingSingleTestInitial extends FetchSingleTestState {}

class SingleTestFetching extends FetchSingleTestState {}

class SingleTestFetched extends FetchSingleTestState {
  final TestModel dailyTestModel;
  final Map<int, Set<String>> languages;

  SingleTestFetched(this.dailyTestModel, this.languages);
}

class SingleTestFetchingFailed extends FetchSingleTestState {
  final Failure failure;

  SingleTestFetchingFailed(this.failure);
}

class SingleDescTestFetched extends FetchSingleTestState {
  final DescTestModel descModel;

  SingleDescTestFetched(this.descModel);
}
