import 'package:gpsc_prep_app/domain/entities/product_model.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:json_annotation/json_annotation.dart';

part 'test_model.g.dart';

@JsonSerializable()
class TestModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "duration")
  int duration;
  @JsonKey(name: "no_questions")
  int noQuestions;
  @JsonKey(name: "test_type")
  TestType testType;
  @JsonKey(name: "total_marks")
  int totalMarks;
  @JsonKey(name: "omr_link")
  String? omrLink;
  @JsonKey(name: "available_at")
  DateTime? availableAt;
  @JsonKey(name: "created_at")
  DateTime? createdAt;
  @JsonKey(name: "total_attempts")
  int? totalAttempt;
  @JsonKey(name: "single_assessment_price")
  ProductModel? singleProduct;
  @JsonKey(name: "double_assessment_price")
  ProductModel? dualProduct;
  @JsonKey(name: "allowed_languages")
  List<String>? allowedLanguages;

  TestModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.noQuestions,
    required this.testType,
    required this.totalMarks,
    this.omrLink,
    this.availableAt,
    this.createdAt,
    this.totalAttempt,
    this.singleProduct,
    this.dualProduct,
    this.allowedLanguages,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TestModelToJson(this);
}
