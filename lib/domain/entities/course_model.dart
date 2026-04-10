import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/product_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

@JsonSerializable()
class CourseModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "description")
  String description;
  @JsonKey(name: "test_type")
  CourseTestType? testType;
  @JsonKey(name: "single_product")
  ProductModel singleProduct;
  @JsonKey(name: "dual_product")
  ProductModel? dualProduct;

  @JsonKey(name: "tests")
  final CourseTestsModel? tests;

  CourseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.testType,
    required this.singleProduct,
    required this.tests,
    this.dualProduct,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseModelToJson(this);
}

@JsonSerializable()
class CourseTestsModel {
  @JsonKey(name: "prelims")
  final List<TestModel>? prelims;

  @JsonKey(name: "descriptive")
  final List<DescTestModel>? descriptive;

  CourseTestsModel({this.prelims, this.descriptive});

  factory CourseTestsModel.fromJson(Map<String, dynamic> json) =>
      _$CourseTestsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseTestsModelToJson(this);
}
