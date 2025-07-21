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

Map<String, dynamic> _$UserPayloadToJson(UserPayload instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('auth_id', instance.authID);
  val['email'] = instance.email;
  val['password'] = instance.password;
  val['full_name'] = instance.name;
  val['role'] = instance.role;
  writeNotNull('address', instance.address);
  writeNotNull('number', instance.number);
  writeNotNull('profile_picture', instance.profilePicture);
  return val;
}
