import 'package:json_annotation/json_annotation.dart';

part 'admin_stats_model.g.dart';

@JsonSerializable()
class AdminStatsModel {
  @JsonKey(name: 'total_mentors')
  final int totalMentors;
  @JsonKey(name: 'total_courses')
  final int totalCourses;

  AdminStatsModel({required this.totalMentors, required this.totalCourses});

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminStatsModelToJson(this);
}
