part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(
    this.profile, {
    this.experiences = const [],
    this.learningStats = const LearningStats(),
    this.certificates = const [],
    this.completionResult,
  });

  final ProfileEntity profile;
  final List<ExperienceEntity> experiences;
  final LearningStats learningStats;
  final List<CertificatePreview> certificates;
  final ProfileCompletionResult? completionResult;

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    List<ExperienceEntity>? experiences,
    LearningStats? learningStats,
    List<CertificatePreview>? certificates,
    ProfileCompletionResult? completionResult,
  }) {
    return ProfileLoaded(
      profile ?? this.profile,
      experiences: experiences ?? this.experiences,
      learningStats: learningStats ?? this.learningStats,
      certificates: certificates ?? this.certificates,
      completionResult: completionResult ?? this.completionResult,
    );
  }

  @override
  List<Object?> get props => [profile, experiences, learningStats, certificates, completionResult];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating(this.profile);

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
