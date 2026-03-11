part of 'all_test_bloc.dart';

@immutable
abstract class AllTestEvent {
  const AllTestEvent();
}

class FetchAllTests extends AllTestEvent {}
