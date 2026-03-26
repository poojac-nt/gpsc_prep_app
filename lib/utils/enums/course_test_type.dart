import 'package:json_annotation/json_annotation.dart';

enum CourseTestType {
  @JsonValue('prelims')
  prelims,
  @JsonValue('mains')
  mains,
}

extension CourseTestTypeExtension on CourseTestType {
  String get displayName {
    switch (this) {
      case CourseTestType.prelims:
        return 'Prelims';
      case CourseTestType.mains:
        return 'Mains';
    }
  }
}
