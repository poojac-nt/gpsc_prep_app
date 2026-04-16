import 'package:gpsc_prep_app/domain/entities/product_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'desc_test_model.g.dart';

@JsonSerializable()
class DescTestModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "no_questions")
  int noQuestions;
  @JsonKey(name: "total_marks")
  int totalMarks;
  @JsonKey(name: "created_at")
  String createdAt;
  @JsonKey(name: "total_attempts")
  int? totalAttempt;
  @JsonKey(name: "single_assessment_price")
  ProductModel? singleProduct;
  @JsonKey(name: "double_assessment_price")
  ProductModel? dualProduct;

  DescTestModel({
    required this.id,
    required this.name,
    required this.totalMarks,
    required this.noQuestions,
    required this.createdAt,
    this.dualProduct,
    this.singleProduct,
    this.totalAttempt,
  });

  factory DescTestModel.fromJson(Map<String, dynamic> json) =>
      _$DescTestModelFromJson(json);

  Map<String, dynamic> toJson() => _$DescTestModelToJson(this);
}
