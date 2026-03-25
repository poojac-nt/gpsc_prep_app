import 'package:json_annotation/json_annotation.dart';

part 'subject_model.g.dart';

@JsonSerializable()
class SubjectModel {
  @JsonKey(name: "subject_id")
  int subjectId;
  @JsonKey(name: "subject_name")
  String subjectName;

  SubjectModel({required this.subjectId, required this.subjectName});

  factory SubjectModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectModelToJson(this);
}
