import 'package:json_annotation/json_annotation.dart';


part 'user_purchase_payload.g.dart';

@JsonSerializable()
class UserPurchasePayload {
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "course_id")
  int courseId;
  @JsonKey(name: "product_id")
  String productId;
  @JsonKey(name: "purchase_token")
  String purchaseToken;

  UserPurchasePayload({
    required this.userId,
    required this.courseId,
    required this.productId,
    required this.purchaseToken,
  });

  factory UserPurchasePayload.fromJson(Map<String, dynamic> json) =>
      _$UserPurchasePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$UserPurchasePayloadToJson(this);
}
