abstract class SupabaseKeys {
  ///RPC functions
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
  static final String getTestAttemptWithAnalytics =
      'get_test_attempt_with_analytics';
  static final String getOverAllAnalytics = 'get_combined_analytics';
  static final String getDashboardAnalytics = 'dashboard_full_analytics';
  static final String getAccuracyTrend = 'get_accuracy_trends';
  static final String getTestAttemptState = 'get_test_attempt_state';
  static final String submitTestAttempt = 'submit_test_attempt';
  static final String getToppers = 'get_top_3_for_dashboard';
  static final String getCoursesListWithTests =
      'fetch_courses_with_tests_products';
  static final String peerReview = 'get_question_peer_submission';
  static final String detailedPeerReviewPerUser = 'get_answer_with_comments';
  static final String insertPeerReview = 'insert_peer_review';
  static final String submitDescTest = 'submit_descriptive_test';
  static final String getTestWithUnassignedSubmission =
      'get_desc_tests_with_unassigned_submissions';
  static final String getUnassignedStudentsForTest =
      'get_pending_test_submissions';
  static final String rpcDescMentorAssignment =
      'rpc_insert_desc_mentor_assignments_bulk';
  static final String mentorDashboard = 'rpc_mentor_dashboard';
  static final String mentorSubmission = 'rpc_mentor_submissions';
  static final String getAdminDashboardStats = 'get_admin_stats';
  static final String getMentorList = 'get_mentors_with_subjects';
  static final String fetchMentorTestSubmissions =
      'rpc_mentor_test_submissions';
  static final String getSubmissionsReport = 'get_submission_report';
  static final String submitMentorEvaluation = 'insert_desc_mentor_review';
  static final String editMentor = 'update_mentor_details';
  static final String fetchStudentTestReview = 'get_desc_test_review';
  static final String getSubmittedFreeDescTests =
      'get_submitted_free_desc_tests';
  static final String getAllTests = 'fetch_all_tests_grouped';
  static final String testWithoutCourseMCQ = 'test_without_course_mcq';
  static final String descTestWithoutCourse = 'test_without_course_desc';
  static final String getCourseWithTests = 'get_course_with_tests';
  static final String getTop3Scorers = 'get_top_3_scorers';

  ///table
  static final String usersTable = 'users';
  static final String questionsTable = 'questions';
  static final String testsTable = 'tests';
  static final String testQuestionTable = 'test_questions';
  static final String testResultsTable = 'test_results';
  static final String config = 'config';
  static final String descTests = 'desc_tests';
  static final String descTestResult = 'desc_test_detailed_results';
  static final String descTestSubmissions = 'desc_test_submissions';
  static final String testDetailedResults = 'test_detailed_results';
  static final String studyMaterial = 'study_material';
  static final String userTests = 'user_tests';
  static final String courseTable = 'courses';
  static final String subjects = 'subjects';
  static final String package = 'package';
  static final String userPurchase = 'user_purchase';
  static final String descMentorAssignment = 'desc_mentor_assignment';
  static final String peerReviewTable = 'peer_review';
  static final String productsTable = 'products';
  static final String notificationsTable = 'notifications';

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
  static final String mentorReview = 'mentor_review';

  ///Edge functions
  static final String createMentor = 'create-mentor';
  static final String deleteUser = 'delete_user';
  static final String verifyPurchase = 'verify_purchase';
}
