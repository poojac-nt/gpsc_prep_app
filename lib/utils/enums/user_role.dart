enum UserRole {
  student,
  mentor,
  admin;

  String get role {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.mentor:
        return 'Mentor';
      case UserRole.admin:
        return 'Admin';
    }
  }

  @override
  String toString() => role;

  // Convert string to UserRole (case-sensitive for now)
  static UserRole fromString(String role) {
    switch (role) {
      case 'Student':
        return UserRole.student;
      case 'Mentor':
        return UserRole.mentor;
      case 'Admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Invalid user role: $role');
    }
  }
}
