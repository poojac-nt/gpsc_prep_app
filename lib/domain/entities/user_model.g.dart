// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt(),
  authID: json['auth_id'] as String,
  role: const UserRoleConverter().fromJson(json['role'] as String),
  name: json['full_name'] as String,
  email: json['user_email'] as String,
  address: json['address'] as String?,
  number: (json['number'] as num?)?.toInt(),
  profilePicture: json['profile_picture'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'auth_id': instance.authID,
  'role': const UserRoleConverter().toJson(instance.role),
  'full_name': instance.name,
  'user_email': instance.email,
  'address': instance.address,
  'number': instance.number,
  'profile_picture': instance.profilePicture,
};
