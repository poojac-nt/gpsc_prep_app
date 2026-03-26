part of 'daily_descriptive_test_bloc.dart';

@immutable
sealed class DailyDescTestState {}

/// Initial state
final class DailyTestInitial extends DailyDescTestState {}

/// Fetching descriptive tests
final class DailyDescTestFetching extends DailyDescTestState {}

/// Fetched descriptive tests successfully
final class DailyDescTestFetched extends DailyDescTestState {
  final List<DescTestModel> dailyTestModel;
  final Map<int, List<DescAnswerModel>> answersMap;
  final Map<int, MainsTestReviewModel?> reviewsMap;
  final bool hasReachedMax;
  final bool isFetchingMore;
  final int offset;

  DailyDescTestFetched(
    this.dailyTestModel,
    this.answersMap,
    this.reviewsMap, {
    this.hasReachedMax = false,
    this.isFetchingMore = false,
    this.offset = 0,
  });

  DailyDescTestFetched copyWith({
    List<DescTestModel>? dailyTestModel,
    Map<int, List<DescAnswerModel>>? answersMap,
    Map<int, MainsTestReviewModel?>? reviewsMap,
    bool? hasReachedMax,
    bool? isFetchingMore,
    int? offset,
  }) {
    return DailyDescTestFetched(
      dailyTestModel ?? this.dailyTestModel,
      answersMap ?? this.answersMap,
      reviewsMap ?? this.reviewsMap,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      offset: offset ?? this.offset,
    );
  }
}

/// Failed fetching descriptive tests
final class DailyDescTestFetchFailed extends DailyDescTestState {
  final Failure failure;

  DailyDescTestFetchFailed(this.failure);
}

/// Submitting descriptive test
final class DescTestSubmit extends DailyDescTestState {}

/// Failed submission
final class DescTestSubmitFailed extends DailyDescTestState {
  final Failure failure;

  DescTestSubmitFailed(this.failure);
}

/// Successful submission
final class DescTestSubmitSuccess extends DailyDescTestState {
  final String message;

  DescTestSubmitSuccess(this.message);
}

/// 🔑 Ongoing test session state (text answers + file answers in memory)
final class DailyDescTestInProgress extends DailyDescTestState {
  final Map<int, String> answers; // text answers
  final Map<int, List<File>> fileCache; // file answers (PDFs/images)

  DailyDescTestInProgress({required this.answers, required this.fileCache});

  DailyDescTestInProgress copyWith({
    Map<int, String>? answers,
    Map<int, List<File>>? fileCache,
  }) {
    return DailyDescTestInProgress(
      answers: answers ?? this.answers,
      fileCache: fileCache ?? this.fileCache,
    );
  }
}

/// 🔑 State to notify user (e.g. when PDF clears text or text clears PDF)
final class DailyDescTestMessage extends DailyDescTestInProgress {
  final String message;

  DailyDescTestMessage({
    required this.message,
    required super.answers,
    required super.fileCache,
  });
}

class AnswerState {
  String text;
  List<File?> files;

  AnswerState({this.text = '', this.files = const []});

  AnswerState copyWith({String? text, List<File?>? files}) {
    return AnswerState(text: text ?? this.text, files: files ?? this.files);
  }
}
