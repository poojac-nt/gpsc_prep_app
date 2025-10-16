import 'package:json_annotation/json_annotation.dart';

part 'study_material_model.g.dart';

@JsonSerializable()
class StudyMaterialModel {
  @JsonKey(name: "id")
  final int id;

  @JsonKey(name: "title")
  final String title;

  @JsonKey(name: "link")
  final String link;

  @JsonKey(name: "test_id")
  final int? testId;

  @JsonKey(name: "created_at")
  final String createdAt;

  @JsonKey(name: "language")
  final String language;

  StudyMaterialModel({
    required this.id,
    required this.title,
    required this.link,
    this.testId,
    required this.createdAt,
    required this.language,
  });

  factory StudyMaterialModel.fromJson(Map<String, dynamic> json) =>
      _$StudyMaterialModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudyMaterialModelToJson(this);
}
