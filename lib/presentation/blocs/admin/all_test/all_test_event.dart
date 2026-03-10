import 'package:equatable/equatable.dart';

abstract class AllTestEvent extends Equatable {
  const AllTestEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllTests extends AllTestEvent {}
