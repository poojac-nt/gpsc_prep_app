import '../../domain/entities/question_model.dart';

extension MCQQuestionParser on String {
  Question parseMCQQuestion() {
    String questionText = '';
    String optA = '';
    String optB = '';
    String optC = '';
    String optD = '';
    String correctAnswer = '';

    final lines = split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('a)')) {
        optA = line.substring(2).trim();
      } else if (line.startsWith('b)')) {
        optB = line.substring(2).trim();
      } else if (line.startsWith('c)')) {
        optC = line.substring(2).trim();
      } else if (line.startsWith('d)')) {
        optD = line.substring(2).trim();
      } else if (line.toLowerCase().startsWith('answer:')) {
        String correctOptionLetter = line.split(':').last.trim().toLowerCase();
        if (correctOptionLetter == 'a') correctAnswer = optA;
        if (correctOptionLetter == 'b') correctAnswer = optB;
        if (correctOptionLetter == 'c') correctAnswer = optC;
        if (correctOptionLetter == 'd') correctAnswer = optD;
      } else {
        // Everything before options assumed as question
        if (questionText.isEmpty) {
          questionText = line;
        } else {
          questionText += ' ' + line;
        }
      }
    }

    return Question(
      question: questionText,
      optA: optA,
      optB: optB,
      optC: optC,
      optD: optD,
      correctAnswer: correctAnswer,
    );
  }
}
