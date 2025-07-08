abstract class SupabaseKeys {
  ///functions
  static final String updateUserInfo = 'update_user_info';
  static final String insertMcqMultiLingual = 'insert_multilingual_questions';
  static final String insertMcqWithTest = 'insert_questions_with_tests';

  ///table
  static final String users = 'users';
  static final String questions = 'questions';
  static final String tests = 'tests';

  ///columns
  static final String email = 'user_email';
  static final String authId = 'auth_id';
}
