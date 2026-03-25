part of 'edit_mentor_bloc.dart';

abstract class EditMentorEvent {}

class FetchSubjects extends EditMentorEvent {}

class UpdateMentor extends EditMentorEvent {
  final int userId;
  final String name;
  final String bio;
  final List<String> subjectExpertise;
  final bool isActive;
  final File? profileImage;

  UpdateMentor({
    required this.userId,
    required this.name,
    required this.bio,
    required this.subjectExpertise,
    required this.isActive,
    this.profileImage,
  });
}

class LoadInitialProfile extends EditMentorEvent {}

class FetchMentorByUserId extends EditMentorEvent {
  final int userId;
  FetchMentorByUserId(this.userId);
}
