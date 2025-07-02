import 'package:json_annotation/json_annotation.dart';

part 'mtf_question_model.g.dart';

@JsonSerializable()
class MTFQuestion {
  final String question;
  final List<String> leftItems;
  final List<String> rightItems;
  final String optA;
  final String optB;
  final String optC;
  final String optD;
  final String
  correctAnswer; // stores the correct option text (e.g., “Option A text”)
  MTFQuestion({
    required this.question,
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
    required this.leftItems,
    required this.rightItems,
    required this.correctAnswer,
  });

  /// Returns the correct option label (A/B/C/D)
  String get correctOptionLabel {
    if (correctAnswer == optA) return 'A';
    if (correctAnswer == optB) return 'B';
    if (correctAnswer == optC) return 'C';
    if (correctAnswer == optD) return 'D';
    return '';
  }

  factory MTFQuestion.fromJson(Map<String, dynamic> json) =>
      _$MTFQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$MTFQuestionToJson(this);
}
