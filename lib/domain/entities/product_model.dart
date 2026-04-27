import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "product_id")
  String productId;
  @JsonKey(name: "price")
  int price;
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "description")
  String description;
  @JsonKey(name: "is_active")
  bool isActive;
  @JsonKey(name: "created_at")
  String createdAt;

  ProductModel({
    required this.id,
    required this.productId,
    required this.price,
    required this.title,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
