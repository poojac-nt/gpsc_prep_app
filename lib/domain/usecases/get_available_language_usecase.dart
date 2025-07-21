import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';

class GetAvailableLanguagesForTestUseCase {
  final TestRepository repository;

  GetAvailableLanguagesForTestUseCase(this.repository);

  Future<Set<String>> call(int testId) async {
    final questionsResult = await repository.fetchTestQuestions(testId);

    return questionsResult.fold(
      (failure) => {'en'},
      (questions) => _getAvailableLanguages(questions),
    );
  }

  Set<String> _getAvailableLanguages(List<QuestionModel> questions) {
    bool hasEnglish = true;
    bool hasHindi = true;
    bool hasGujarati = true;

    for (final q in questions) {
      final en = q.questionEn;
      if (en.questionTxt.trim().isEmpty ||
          en.optA.trim().isEmpty ||
          en.optB.trim().isEmpty ||
          en.optC.trim().isEmpty ||
          en.optD.trim().isEmpty) {
        hasEnglish = false;
      }

      final hi = q.questionHi;
      if (hi == null ||
          hi.questionTxt.trim().isEmpty ||
          hi.optA.trim().isEmpty ||
          hi.optB.trim().isEmpty ||
          hi.optC.trim().isEmpty ||
          hi.optD.trim().isEmpty) {
        hasHindi = false;
      }

      final gj = q.questionGj;
      if (gj == null ||
          gj.questionTxt.trim().isEmpty ||
          gj.optA.trim().isEmpty ||
          gj.optB.trim().isEmpty ||
          gj.optC.trim().isEmpty ||
          gj.optD.trim().isEmpty) {
        hasGujarati = false;
      }
    }

    final available = <String>{};
    if (hasEnglish) available.add('en');
    if (hasHindi) available.add('hi');
    if (hasGujarati) available.add('gj');

    return available;
  }
}
