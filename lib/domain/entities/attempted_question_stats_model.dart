import 'package:json_annotation/json_annotation.dart';

part 'attempted_question_stats_model.g.dart';

@JsonSerializable()
class AttemptedQuestionStat {
  @JsonKey(includeToJson: false)
  final int totalUsers;

  @JsonKey(name: 'question_id')
  final int questionId;

  @JsonKey(name: 'attempted_count')
  final int attemptedCount;

  @JsonKey(name: 'not_attempted_count')
  final int notAttemptedCount;

  AttemptedQuestionStat({
    required this.totalUsers,
    required this.questionId,
    required this.attemptedCount,
    required this.notAttemptedCount,
  });

  /// This is NOT a normal fromJson
  /// because total_users lives outside question object
  static List<AttemptedQuestionStat> fromRpcResponse(List<dynamic> response) {
    final row = response.first as Map<String, dynamic>;
    final totalUsers = row['total_users'] as int;

    final questions = row['questions'] as List;

    return questions.map((q) {
      return AttemptedQuestionStat(
        totalUsers: totalUsers,
        questionId: q['question_id'],
        attemptedCount: q['attempted_count'],
        notAttemptedCount: q['not_attempted_count'],
      );
    }).toList();
  }

  /// Optional JSON support if needed later
  factory AttemptedQuestionStat.fromJson(Map<String, dynamic> json) =>
      _$AttemptedQuestionStatFromJson(json);

  Map<String, dynamic> toJson() => _$AttemptedQuestionStatToJson(this);
}
