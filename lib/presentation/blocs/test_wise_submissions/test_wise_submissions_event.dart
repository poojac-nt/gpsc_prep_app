import 'package:flutter/foundation.dart';
import 'package:gpsc_prep_app/domain/entities/student_list_with_mentor.dart';

@immutable
sealed class TestWiseSubmissionsEvent {}

class FetchTestWisePendingSubmissions extends TestWiseSubmissionsEvent {
  final int testId;
  FetchTestWisePendingSubmissions(this.testId);
}

class ToggleSubmissionSelection extends TestWiseSubmissionsEvent {
  final StudentListWithMentor submission;
  ToggleSubmissionSelection(this.submission);
}

class ClearSubmissionSelection extends TestWiseSubmissionsEvent {}
