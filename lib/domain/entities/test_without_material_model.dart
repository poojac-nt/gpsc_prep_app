import 'package:json_annotation/json_annotation.dart';

part 'test_without_material_model.g.dart';

@JsonSerializable()
class TestWithoutMaterial {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  const TestWithoutMaterial({required this.id, required this.name});

  factory TestWithoutMaterial.fromJson(Map<String, dynamic> json) =>
      _$TestWithoutMaterialFromJson(json);

  Map<String, dynamic> toJson() => _$TestWithoutMaterialToJson(this);
}
