part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested(this.profile);

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

class ProfileLoadExtendedData extends ProfileEvent {
  const ProfileLoadExtendedData(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class ExperienceAddRequested extends ProfileEvent {
  const ExperienceAddRequested(this.experience);

  final ExperienceEntity experience;

  @override
  List<Object?> get props => [experience];
}

class ExperienceUpdateRequested extends ProfileEvent {
  const ExperienceUpdateRequested(this.experience);

  final ExperienceEntity experience;

  @override
  List<Object?> get props => [experience];
}

class ExperienceDeleteRequested extends ProfileEvent {
  const ExperienceDeleteRequested(this.experienceId);

  final String experienceId;

  @override
  List<Object?> get props => [experienceId];
}
