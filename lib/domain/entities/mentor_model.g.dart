// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorModel _$MentorModelFromJson(Map<String, dynamic> json) => MentorModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      subjects: (json['subjects'] as List<dynamic>)
          .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MentorModelToJson(MentorModel instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'subjects': instance.subjects.map((e) => e.toJson()).toList(),
    };
