import 'package:gpsc_prep_app/utils/constants/secrets.dart';

enum Flavor { development, production }

class Environment {
  static Flavor? _flavor;
  static String? _apiUrl;
  static String? _anonKey;
  static String? _serviceKey;

  static void setFlavor(Flavor flavor) {
    _flavor = flavor;
    switch (flavor) {
      case Flavor.development:
        _apiUrl = AppSecrets.devApiUrl;
        _anonKey = AppSecrets.devAnonKey;
        _serviceKey = AppSecrets.devServiceKey;
        break;
      case Flavor.production:
        _apiUrl = AppSecrets.prodApiUrl;
        _anonKey = AppSecrets.prodAnonKey;
        _serviceKey = AppSecrets.prodServiceKey;
        break;
    }
  }

  static Flavor get flavor => _flavor ?? Flavor.development;

  static String get supabaseUrl => _apiUrl ?? '';

  static String get supabaseAnonKey => _anonKey ?? '';

  static String get serviceKey => _serviceKey ?? '';

  static bool get isProduction => _flavor == Flavor.production;

  static bool get isDevelopment => _flavor == Flavor.development;
}
