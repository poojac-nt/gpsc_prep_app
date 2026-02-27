// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeerReviewModel _$PeerReviewModelFromJson(Map<String, dynamic> json) =>
    PeerReviewModel(
      answerId: (json['answer_id'] as num).toInt(),
      fullName: json['full_name'] as String,
      userId: (json['user_id'] as num).toInt(),
      answer: json['answer'],
      timeSinceLatestComment: json['time_since_submission'] as String,
      latestComment: json['latest_comment'] as String?,
    );

Map<String, dynamic> _$PeerReviewModelToJson(PeerReviewModel instance) =>
    <String, dynamic>{
      'answer_id': instance.answerId,
      'full_name': instance.fullName,
      'user_id': instance.userId,
      'answer': instance.answer,
      'latest_comment': instance.latestComment,
      'time_since_submission': instance.timeSinceLatestComment,
    };
