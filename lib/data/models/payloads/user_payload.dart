import 'package:json_annotation/json_annotation.dart';

part 'user_payload.g.dart';

@JsonSerializable()
class UserPayload {
  @JsonKey(name: "auth_id", includeIfNull: false)
  final String? authID;
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "password")
  final String? password;
  @JsonKey(name: "full_name")
  final String name;
  @JsonKey(name: "role")
  final String role;
  @JsonKey(name: "address", includeIfNull: false)
  final String? address;
  @JsonKey(name: "number", includeIfNull: false)
  final int? number;
  @JsonKey(name: "profile_picture", includeIfNull: false)
  final String? profilePicture;

  UserPayload({
    this.authID,
    required this.name,
    required this.email,
    this.password,
    this.role = 'Student',
    this.address,
    this.number,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() => _$UserPayloadToJson(this);
}
