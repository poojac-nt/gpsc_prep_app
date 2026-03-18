class DescFreeTestWithUsers {
  final int testId;
  final String name;
  final int noQuestions;
  final int totalMarks;
  final DateTime createdAt;
  final List<SubmittedUser> users;

  DescFreeTestWithUsers({
    required this.testId,
    required this.name,
    required this.noQuestions,
    required this.totalMarks,
    required this.createdAt,
    required this.users,
  });

  factory DescFreeTestWithUsers.fromJson(Map<String, dynamic> json) {
    return DescFreeTestWithUsers(
      testId: json['test_id'],
      name: json['name'],
      noQuestions: json['no_questions'],
      totalMarks: json['total_marks'],
      createdAt: DateTime.parse(json['created_at']),
      users:
          (json['users'] as List<dynamic>)
              .map((e) => SubmittedUser.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'name': name,
      'no_questions': noQuestions,
      'total_marks': totalMarks,
      'created_at': createdAt.toIso8601String(),
      'users': users.map((e) => e.toJson()).toList(),
    };
  }
}

class SubmittedUser {
  final int userId;
  final String userName;

  SubmittedUser({required this.userId, required this.userName});

  factory SubmittedUser.fromJson(Map<String, dynamic> json) {
    return SubmittedUser(userId: json['user_id'], userName: json['user_name']);
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'user_name': userName};
  }
}
