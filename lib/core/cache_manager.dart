import 'package:gpsc_prep_app/core/helpers/shared_prefs_helper.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/utils/enums/user_role.dart';

class CacheManager {
  final SharedPrefHelper _prefs;

  CacheManager(this._prefs);

  UserModel? _user;

  UserRole? getUserRole() => _user?.role ?? UserRole.student;

  Future<UserModel?> getInitUser() async {
    _user = await _prefs.getUser();
    return _user;
  }

  void setUser(UserModel user) {
    _user = user;
    _prefs.saveUser(user);
  }

  UserModel? get user => _user;

  int getUserId() => _user?.id ?? 0;

  void clearUser() {
    _user = null;
    _prefs.clear();
  }
}
