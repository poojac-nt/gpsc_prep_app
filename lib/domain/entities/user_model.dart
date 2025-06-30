import 'package:json_annotation/json_annotation.dart';

import '../../utils/enums/user_role.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'auth_id')
  final String authID;

  @JsonKey(name: 'role')
  @UserRoleConverter()
  final UserRole role;

  @JsonKey(name: 'full_name')
  final String name;

  @JsonKey(name: 'user_email')
  final String email;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'number')
  final int? number;

  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  UserModel({
    this.id,
    required this.authID,
    required this.role,
    required this.name,
    required this.email,
    this.address,
    this.number,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) => UserRole.fromString(json);

  @override
  String toJson(UserRole role) => role.role;
}
