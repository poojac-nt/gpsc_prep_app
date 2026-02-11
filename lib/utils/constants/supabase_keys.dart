abstract class SupabaseKeys {
  ///functions
  static final String updateUserInfo = 'update_user_info';
  static final String insertMcqWithTest = 'insert_questions_with_tests';
  static final String insertBulkQuestions = 'insert_bulk_questions';
  static final String getTestQuestionsByTestId =
      'get_test_questions_by_test_id';
  static final String getDescTestQuestionsByTestId = 'get_desc_test_questions';
  static final String insertDescWithTest = 'insert_desc_questions_with_tests';
  static final String getQuestionCorrectnessCounts =
      'get_test_question_correctness_counts';
  static final String getTestWithoutStudyMaterialForLanguage =
      'get_tests_without_material_for_language';
  static final String insertTestWithStudyMaterial =
      'insert_test_with_study_material';
  static final String checkUserExist = 'check_user_exists';
  static final String getOptionMatrixForTest = 'get_test_question_option_stats';
  static final String getAttemptedQuestionStats =
      'get_test_question_attempts_summary_v2';
  static final String getUserTestResultWithTopScore =
      'get_user_test_result_with_top_score';
  static final String getUserTestReview = 'get_user_test_review';
  static final String getOverAllAnalytics = 'get_combined_analytics';
  static final String getDashboardAnalytics = 'dashboard_full_analytics';
  static final String getAccuracyTrend = 'get_accuracy_trends';
  static final String getTestAttemptState = 'get_test_attempt_state';
  static final String submitTestAttempt = 'submit_test_attempt';
  static final String getUserTestReviewByQuestionType =
      'get_test_question_type_analysis';
  static final String getUserTestReviewBySubject =
      'get_test_subject_wise_analytics';
  static final String getPrelimsTopper = 'get_top_3_prelims_users';

  ///table
  static final String usersTable = 'users';
  static final String questionsTable = 'questions';
  static final String testsTable = 'tests';
  static final String testQuestionTable = 'test_questions';
  static final String testResultsTable = 'test_results';
  static final String config = 'config';
  static final String descTests = 'desc_tests';
  static final String descTestResult = 'desc_test_detailed_results';
  static final String testDetailedResults = 'test_detailed_results';
  static final String studyMaterial = 'study_material';
  static final String userTests = 'user_tests';

  ///columns
  static final String email = 'user_email';
  static final String authId = 'auth_id';
  static final String fcmToken = 'fcm_token';
  static final String studyTitle = 'title';
  static final String studyLanguage = 'language';
  static final String studyLink = 'link';
  static final String studTestId = 'test_id';

  ///Buckets
  static final String answers = 'answers';
  static final String profilePicture = 'profile-picture';
}
