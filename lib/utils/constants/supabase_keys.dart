abstract class SupabaseKeys {
  ///functions
  static final String updateUserInfo = 'update_user_info';
  static final String insertMcqMultiLingual = 'insert_multilingual_questions';
  static final String insertMcqWithTest = 'insert_questions_with_tests';
  static final String insertMcqWithTest2 = 'insert_questions_with_tests_v2';
  static final String insertBulkQuestions = 'insert_bulk_questions';
  static final String getTestQuestionsByTestId =
      'get_test_questions_by_test_id';
  static final String getAttemptedTestStats = 'fetch_attempted_test_stats';

  ///table
  static final String usersTable = 'users';
  static final String questionsTable = 'questions';
  static final String testsTable = 'tests';
  static final String testQuestionTable = 'test_questions';
  static final String testResultsTable = 'test_results';
  static final String config = 'config';

  ///columns
  static final String email = 'user_email';
  static final String authId = 'auth_id';
  static final String fcmToken = 'fcm_token';
}
