import 'package:json_annotation/json_annotation.dart';

part 'question_model.g.dart';

@JsonSerializable()
class Question {
  final String question;
  final String optA;
  final String optB;
  final String optC;
  final String optD;
  final String questionType;
  final String correctAnswer;
  final String
  explanation; // stores the correct option text (e.g., “Option A text”)
  Question({
    required this.question,
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
    required this.questionType,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  static List<Question> sampleQuestion() {
    return [
      Question(
        question: 'What is Flutter ?',
        optA: "A. Flutter is a framework",
        optB: "B. Flutter is a programming language",
        optC: " C. Flutter is a widget library",
        optD: "D. Flutter is a mobile app development platform",
        questionType: 'mcq',
        correctAnswer: "D. Flutter is a mobile app development platform",
        explanation:
            "Flutter is not a programming language — it’s a mobile app development framework created by Google. It allows developers to build cross-platform apps using a single codebase in Dart, making it faster and more efficient to develop for Android, iOS, and other platforms.",
      ),
      Question(
        question: """
        **Match the followning options to countries**
        | Column A | Column B |
        | --- | --- |
        | 1. Delhi | a. State |
        | 2. India | b. Country |
        | 3. America | c. America |
        """,
        optA: "A. 1-A,2-B,3-C",
        optB: "B. 3-A,2-B,1-C",
        optC: "C. 2-A,3-B,C-1",
        optD: "D. 2-C,3-A,1-B",
        questionType: 'mtf',
        correctAnswer: " B. 3-A,2-B,1-C",
        explanation:
            "Mitochondria are known as the powerhouse of the cell because they generate energy (ATP) through cellular respiration. This energy is essential for all cell activities.",
      ),
      Question(
        question:
            """ **Consider the following statements regarding the Indus Valley Civilization:**
    1. The civilization was primarily urban in nature.
    2. The people of Indus Valley Civilization used iron extensively.
    3. Harappa and Mohenjo-Daro were major cities of this civilization.
    4. The script used by them has been successfully deciphered.
    """,
        optA: " A. 1, 2 and 3 only",
        optB: "B. 1 and 3 only",
        optC: "C. 2, 3 and 4 only",
        optD: "D. 1,2 3 and 4",
        questionType: 'statement',
        correctAnswer: "C. 2, 3 and 4 only",
        explanation:
            "Flutter is not a programming language — it’s a mobile app development framework created by Google. It allows developers to build cross-platform apps using a single codebase in Dart, making it faster and more efficient to develop for Android, iOS, and other platforms.",
      ),
      Question(
        question: "**The powerhouse of the cell is the _________**",
        optA: "A. Nucleus",
        optB: "B. Mitochondria",
        optC: "C. Ribosome",
        optD: "D. Cytoplasm",
        questionType: 'mcq',
        correctAnswer: "D. Cytoplasm",
        explanation:
            "Mitochondria are known as the powerhouse of the cell because they generate energy (ATP) through cellular respiration. This energy is essential for all cell activities.",
      ),
    ];
  }

  List<String> getOptions() {
    return [optA, optB, optC, optD];
  }
}
