// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPayload _$UserPayloadFromJson(Map<String, dynamic> json) => UserPayload(
  authID: json['auth_id'] as String?,
  name: json['full_name'] as String,
  email: json['email'] as String,
  password: json['password'] as String?,
  role: json['role'] as String? ?? 'Student',
  address: json['address'] as String?,
  number: (json['number'] as num?)?.toInt(),
  profilePicture: json['profile_picture'] as String?,
);

Map<String, dynamic> _$UserPayloadToJson(UserPayload instance) =>
    <String, dynamic>{
      if (instance.authID case final value?) 'auth_id': value,
      'email': instance.email,
      'password': instance.password,
      'full_name': instance.name,
      'role': instance.role,
      if (instance.address case final value?) 'address': value,
      if (instance.number case final value?) 'number': value,
      if (instance.profilePicture case final value?) 'profile_picture': value,
    };
