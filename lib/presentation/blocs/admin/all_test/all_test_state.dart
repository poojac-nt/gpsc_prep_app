part of 'all_test_bloc.dart';

@immutable
abstract class AllTestState {
  const AllTestState();
}

class AllTestInitial extends AllTestState {}

class AllTestLoading extends AllTestState {}

class AllTestLoaded extends AllTestState {
  final AllTestsModel allTests;

  const AllTestLoaded(this.allTests);
}

class AllTestError extends AllTestState {
  final String message;

  const AllTestError(this.message);
}
