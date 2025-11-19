// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
