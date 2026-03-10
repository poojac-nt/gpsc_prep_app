import 'package:equatable/equatable.dart';
import '../../../../domain/entities/all_tests_model.dart';

abstract class AllTestState extends Equatable {
  const AllTestState();

  @override
  List<Object?> get props => [];
}

class AllTestInitial extends AllTestState {}

class AllTestLoading extends AllTestState {}

class AllTestLoaded extends AllTestState {
  final AllTestsModel allTests;

  const AllTestLoaded(this.allTests);

  @override
  List<Object?> get props => [allTests];
}

class AllTestError extends AllTestState {
  final String message;

  const AllTestError(this.message);

  @override
  List<Object?> get props => [message];
}
