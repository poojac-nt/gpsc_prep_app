import 'package:json_annotation/json_annotation.dart';

part 'product_payload.g.dart';

@JsonSerializable()
class ProductPayload {
  @JsonKey(name: "title")
  final String title;
  @JsonKey(name: "product_id")
  final String productId;
  @JsonKey(name: "price")
  final int price;
  @JsonKey(name: "description")
  final String description;
  @JsonKey(name: "is_active")
  final bool isActive;

  ProductPayload({
    required this.title,
    required this.productId,
    required this.price,
    required this.description,
    this.isActive = true,
  });

  factory ProductPayload.fromJson(Map<String, dynamic> json) =>
      _$ProductPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$ProductPayloadToJson(this);
}
