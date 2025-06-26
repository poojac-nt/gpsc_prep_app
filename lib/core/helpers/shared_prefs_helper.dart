import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  late SharedPreferences _prefs;

  SharedPrefHelper() {
    init();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
}
