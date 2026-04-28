// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardModel _$LeaderboardModelFromJson(Map<String, dynamic> json) =>
    LeaderboardModel(
      testType: json['test_type'] as String,
      rank: (json['rank'] as num).toInt(),
      studentName: json['student_name'] as String,
      totalMarks: (json['total_marks'] as num).toInt(),
      testName: json['test_name'] as String,
      profilePicture: json['profile_picture'] as String?,
    );

Map<String, dynamic> _$LeaderboardModelToJson(LeaderboardModel instance) =>
    <String, dynamic>{
      'test_type': instance.testType,
      'rank': instance.rank,
      'student_name': instance.studentName,
      'test_name': instance.testName,
      'total_marks': instance.totalMarks,
      'profile_picture': instance.profilePicture,
    };
