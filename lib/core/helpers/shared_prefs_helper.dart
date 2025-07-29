import 'dart:convert';

import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  late SharedPreferences _prefs;

  SharedPrefHelper() {
    init();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _prefs.setString('user', jsonString);
  }

  Future<UserModel?> getUser() async {
    final jsonString = _prefs.getString('user');
    if (jsonString == null) return null;
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return UserModel.fromJson(jsonMap);
  }

  void saveUserLanguage(String lang) {
    _prefs.setString('userLanguage', lang);
  }

  String getUserLanguage() {
    return _prefs.getString('userLanguage') ?? 'en';
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
