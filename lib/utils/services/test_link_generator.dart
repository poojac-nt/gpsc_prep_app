

enum TestType { mcq, desc }

extension TestTypeExtension on TestType {
  String get name {
    switch (this) {
      case TestType.mcq:
        return 'mcq';
      case TestType.desc:
        return 'desc';
    }
  }
}

class DeepLinkGenerator {
  static const String _baseUrl = 'https://starics.netlify.app';
  static const String _packageName = 'app.starics';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=$_packageName';

  /// Generate a shareable URL with the test type and ID
  static String generateShareableUrl({
    required int testId,
    required TestType testType,
  }) {
    return '$_baseUrl/openTest?type=${testType.name}&id=$testId';
  }
}
