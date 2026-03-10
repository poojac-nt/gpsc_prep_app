enum TestType { mcq, desc, prelims, mains }

extension TestTypeExtension on TestType {
  String get name {
    switch (this) {
      case TestType.mcq:
        return 'mcq';
      case TestType.desc:
        return 'desc';
      case TestType.prelims:
        return 'prelims';
      case TestType.mains:
        return 'mains';
    }
  }
}

class DeepLinkGenerator {
  static const String _baseUrl = 'https://starics.netlify.app';

  /// Generate a shareable URL with the test type and ID
  static String generateShareableUrl({
    required int testId,
    required TestType testType,
  }) {
    return '$_baseUrl/openTest?type=${testType.name}&id=$testId';
  }

  static String generateStudyMaterialLink({
    required int studyMaterialId,
    required String languageCode,
  }) {
    return '$_baseUrl/openMaterial?id=$studyMaterialId&language=$languageCode';
  }
}
