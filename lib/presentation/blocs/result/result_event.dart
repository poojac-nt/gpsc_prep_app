part of 'result_bloc.dart';

@immutable
sealed class ResultEvent {}

class FetchResultData extends ResultEvent {
  final int testId;

  FetchResultData(this.testId);
}
