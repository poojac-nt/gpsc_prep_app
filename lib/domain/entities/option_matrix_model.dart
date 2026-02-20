import 'package:json_annotation/json_annotation.dart';

part 'option_matrix_model.g.dart';

@JsonSerializable()
class OptionMatrixModel {
  @JsonKey(name: "question_id")
  int questionId;

  @JsonKey(name: "selected_option")
  String selectedOption;

  @JsonKey(name: "total_users")
  int totalUsers;

  OptionMatrixModel({
    required this.questionId,
    required this.selectedOption,
    required this.totalUsers,
  });

  factory OptionMatrixModel.fromJson(Map<String, dynamic> json) =>
      _$OptionMatrixModelFromJson(json);

  Map<String, dynamic> toJson() => _$OptionMatrixModelToJson(this);
}
