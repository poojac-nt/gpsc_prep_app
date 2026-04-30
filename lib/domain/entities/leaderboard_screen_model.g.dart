// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_screen_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardScreenModel _$LeaderboardScreenModelFromJson(
        Map<String, dynamic> json) =>
    LeaderboardScreenModel(
      mains: (json['mains'] as List<dynamic>)
          .map((e) => Main.fromJson(e as Map<String, dynamic>))
          .toList(),
      prelims: (json['prelims'] as List<dynamic>)
          .map((e) => Main.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LeaderboardScreenModelToJson(
        LeaderboardScreenModel instance) =>
    <String, dynamic>{
      'mains': instance.mains,
      'prelims': instance.prelims,
    };

Main _$MainFromJson(Map<String, dynamic> json) => Main(
      rank: (json['rank'] as num).toInt(),
      testId: (json['test_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      fullName: json['full_name'] as String,
      testName: json['test_name'] as String,
      totalMarks: (json['total_marks'] as num?)?.toInt(),
      profilePicture: json['profile_picture'] as String?,
      score: (json['score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MainToJson(Main instance) => <String, dynamic>{
      'rank': instance.rank,
      'test_id': instance.testId,
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'test_name': instance.testName,
      'total_marks': instance.totalMarks,
      'profile_picture': instance.profilePicture,
      'score': instance.score,
    };
