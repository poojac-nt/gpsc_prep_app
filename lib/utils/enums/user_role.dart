enum UserRole {
  student,
  mentor,
  admin;

  String get role {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.mentor:
        return 'mentor';
      case UserRole.admin:
        return 'admin';
    }
  }

  @override
  String toString() => role;

  // Convert string to UserRole (case-sensitive for now)
  static UserRole fromString(String role) {
    switch (role) {
      case 'student':
        return UserRole.student;
      case 'mentor':
        return UserRole.mentor;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Invalid user role: $role');
    }
  }
}

enum AppVersionStatus { upToDate, needsUpdate }
