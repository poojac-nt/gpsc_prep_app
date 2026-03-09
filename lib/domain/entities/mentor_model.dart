import 'package:json_annotation/json_annotation.dart';

import 'subject_model.dart';
import 'user_model.dart';

part 'mentor_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MentorModel {
  final UserModel user;
  final List<SubjectModel> subjects;

  MentorModel({required this.user, required this.subjects});

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    final user = UserModel.fromJson(json['user_data']); // ✅ use json['user']

    final subjects =
        (json['subjects'] as List<dynamic>?)
            ?.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return MentorModel(user: user, subjects: subjects);
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'subjects': subjects.map((e) => e.toJson()).toList(),
  };
}
