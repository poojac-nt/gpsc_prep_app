abstract class AdminEvent {}

class FetchAdminStats extends AdminEvent {}

class FetchMentorList extends AdminEvent {}

class UpdateMentor extends AdminEvent {
  final int userId;
  final String name;
  final String bio;
  final List<String> subjectExpertise;
  final bool isActive;
  UpdateMentor({
    required this.userId,
    required this.name,
    required this.bio,
    required this.subjectExpertise,
    required this.isActive,
  });
}

class DeleteMentor extends AdminEvent {
  final int userId;
  DeleteMentor(this.userId);
}
