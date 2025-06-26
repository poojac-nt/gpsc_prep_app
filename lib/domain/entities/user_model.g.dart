// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt(),
  role: const UserRoleConverter().fromJson(json['role'] as String),
  name: json['full_name'] as String,
  email: json['email'] as String,
  address: json['address'] as String?,
  number: (json['number'] as num?)?.toInt(),
  profilePicture: json['profile_picture'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'role': const UserRoleConverter().toJson(instance.role),
  'full_name': instance.name,
  'email': instance.email,
  'address': instance.address,
  'number': instance.number,
  'profile_picture': instance.profilePicture,
};
