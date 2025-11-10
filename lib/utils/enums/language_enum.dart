enum LanguageEnum {
  en,
  hi,
  gj;

  String get language {
    switch (this) {
      case LanguageEnum.en:
        return 'English';
      case LanguageEnum.hi:
        return 'Hindi';
      case LanguageEnum.gj:
        return 'Gujarati';
    }
  }

  @override
  String toString() => language;

  static LanguageEnum fromString(String languageCode) {
    switch (languageCode) {
      case 'en':
        return LanguageEnum.en;
      case 'hi':
        return LanguageEnum.hi;
      case 'gj':
        return LanguageEnum.gj;
      default:
        throw ArgumentError('Invalid language code: $languageCode');
    }
  }
}
