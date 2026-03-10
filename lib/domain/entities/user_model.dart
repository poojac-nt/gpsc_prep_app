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
  @JsonKey(name: 'bio')
  final String? bio;

  @JsonKey(name: 'is_active')
  final bool? isActive;
  UserModel({
    this.id,
    required this.authID,
    required this.role,
    required this.name,
    required this.email,
    this.address,
    this.number,
    this.profilePicture,
    this.bio,
    this.isActive,
  });

  /// Copy constructor
  UserModel copyWith({
    int? id,
    String? authID,
    UserRole? role,
    String? name,
    String? email,
    String? address,
    int? number,
    String? profilePicture,
    String? bio,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      authID: authID ?? this.authID,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      number: number ?? this.number,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

class UserRoleConverter implements JsonConverter<UserRole, dynamic> {
  const UserRoleConverter();

  @override
  UserRole fromJson(dynamic json) {
    if (json is String) {
      return UserRole.fromString(json);
    }

    if (json is Map<String, dynamic>) {
      // Extract the actual value safely
      final value = json.values.first;
      return UserRole.fromString(value.toString());
    }

    throw Exception('Invalid role format: $json');
  }

  @override
  dynamic toJson(UserRole role) => role.role;
}
