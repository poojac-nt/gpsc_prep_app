import 'package:flutter/cupertino.dart';

import '../../../../../domain/entities/question_language_model.dart';

@immutable
sealed class TestEvent {}

class SubmitTest extends TestEvent {
  final int testId;
  final List<int> marks;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOptions;
  final List<bool> answeredStatus;

  SubmitTest(
    this.testId,
    this.marks,
    this.questions,
    this.selectedOptions,
    this.answeredStatus,
  );
}

class InsertTestResultEvent extends TestEvent {}

class FetchSingleTestResultEvent extends TestEvent {
  final int testId;

  FetchSingleTestResultEvent({required this.testId});
}
