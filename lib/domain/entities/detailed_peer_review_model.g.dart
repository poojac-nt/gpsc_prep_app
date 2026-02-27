// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_peer_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailedPeerReviewModel _$DetailedPeerReviewModelFromJson(
        Map<String, dynamic> json) =>
    DetailedPeerReviewModel(
      answerId: (json['answer_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      fullName: json['full_name'] as String,
      answer: json['answer'],
      comments: (json['comments'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DetailedPeerReviewModelToJson(
        DetailedPeerReviewModel instance) =>
    <String, dynamic>{
      'answer_id': instance.answerId,
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'answer': instance.answer,
      'comments': instance.comments,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      comment: json['comment'] as String,
      commentId: (json['comment_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewerId: (json['reviewer_id'] as num).toInt(),
      reviewerName: json['reviewer_name'] as String,
      timeSinceComment: json['time_since_comment'] as String,
      timeSinceCommentText: json['time_since_comment_text'] as String,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'comment': instance.comment,
      'comment_id': instance.commentId,
      'created_at': instance.createdAt.toIso8601String(),
      'reviewer_id': instance.reviewerId,
      'reviewer_name': instance.reviewerName,
      'time_since_comment': instance.timeSinceComment,
      'time_since_comment_text': instance.timeSinceCommentText,
    };
