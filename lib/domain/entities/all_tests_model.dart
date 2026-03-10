import 'package:json_annotation/json_annotation.dart';
import 'test_model.dart';
import 'desc_test_model.dart';

part 'all_tests_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AllTestsModel {
  @JsonKey(name: "mcq")
  final List<TestModel> mcq;

  @JsonKey(name: "prelims")
  final List<TestModel> prelims;

  @JsonKey(name: "descriptive")
  final List<DescTestModel> descriptive;

  @JsonKey(name: "mains")
  final List<DescTestModel> mains;

  AllTestsModel({
    required this.mcq,
    required this.prelims,
    required this.descriptive,
    required this.mains,
  });

  factory AllTestsModel.fromJson(Map<String, dynamic> json) =>
      _$AllTestsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AllTestsModelToJson(this);
}
