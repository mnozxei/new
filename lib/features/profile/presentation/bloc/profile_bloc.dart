import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/services/profile_completion_service.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required ProfileRepository profileRepository,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        _profileRepository = profileRepository,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
    on<ProfileLoadExtendedData>(_onProfileLoadExtendedData);
    on<ExperienceAddRequested>(_onExperienceAddRequested);
    on<ExperienceUpdateRequested>(_onExperienceUpdateRequested);
    on<ExperienceDeleteRequested>(_onExperienceDeleteRequested);
  }

  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final ProfileRepository _profileRepository;

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final profile = await _getUserProfile(event.userId);

      if (profile != null) {
        emit(ProfileLoaded(profile));
        // Automatically load extended data
        add(ProfileLoadExtendedData(event.userId));
      } else {
        emit(const ProfileError('Profile not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onProfileLoadExtendedData(
    ProfileLoadExtendedData event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        // Load all extended data in parallel
        final results = await Future.wait([
          _profileRepository.getExperiences(event.userId),
          _profileRepository.getLearningStats(event.userId),
          _profileRepository.getCertificates(event.userId, limit: 3),
        ]);

        final experiences = results[0] as List<ExperienceEntity>;
        final learningStats = results[1] as LearningStats;
        final certificates = results[2] as List<CertificatePreview>;

        // Calculate profile completion
        final completionResult = ProfileCompletionService.compute(
          profile: currentState.profile,
          experiencesCount: experiences.length,
          completedCoursesCount: learningStats.completedCount,
          certificatesCount: certificates.length,
        );

        emit(currentState.copyWith(
          experiences: experiences,
          learningStats: learningStats,
          certificates: certificates,
          completionResult: completionResult,
        ));
      } catch (e) {
        // Don't fail the whole profile load if extended data fails
        // Just keep the current state with empty extended data
      }
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.profile));

      try {
        final updatedProfile = await _updateUserProfile(event.profile);

        // Recalculate completion after update
        final completionResult = ProfileCompletionService.compute(
          profile: updatedProfile,
          experiencesCount: currentState.experiences.length,
          completedCoursesCount: currentState.learningStats.completedCount,
          certificatesCount: currentState.certificates.length,
        );

        emit(ProfileLoaded(
          updatedProfile,
          experiences: currentState.experiences,
          learningStats: currentState.learningStats,
          certificates: currentState.certificates,
          completionResult: completionResult,
        ));
      } catch (e) {
        emit(ProfileError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final profile = await _getUserProfile(currentState.profile.id);
        if (profile != null) {
          emit(ProfileLoaded(
            profile,
            experiences: currentState.experiences,
            learningStats: currentState.learningStats,
            certificates: currentState.certificates,
            completionResult: currentState.completionResult,
          ));
          // Reload extended data
          add(ProfileLoadExtendedData(profile.id));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onExperienceAddRequested(
    ExperienceAddRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final newExperience = await _profileRepository.addExperience(
          currentState.profile.id,
          event.experience,
        );

        final updatedExperiences = [newExperience, ...currentState.experiences];

        // Recalculate completion
        final completionResult = ProfileCompletionService.compute(
          profile: currentState.profile,
          experiencesCount: updatedExperiences.length,
          completedCoursesCount: currentState.learningStats.completedCount,
          certificatesCount: currentState.certificates.length,
        );

        emit(currentState.copyWith(
          experiences: updatedExperiences,
          completionResult: completionResult,
        ));
      } catch (e) {
        emit(ProfileError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onExperienceUpdateRequested(
    ExperienceUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final updatedExperience = await _profileRepository.updateExperience(
          currentState.profile.id,
          event.experience,
        );

        final updatedExperiences = currentState.experiences.map((exp) {
          return exp.id == updatedExperience.id ? updatedExperience : exp;
        }).toList();

        emit(currentState.copyWith(experiences: updatedExperiences));
      } catch (e) {
        emit(ProfileError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onExperienceDeleteRequested(
    ExperienceDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        await _profileRepository.deleteExperience(
          currentState.profile.id,
          event.experienceId,
        );

        final updatedExperiences = currentState.experiences
            .where((exp) => exp.id != event.experienceId)
            .toList();

        // Recalculate completion
        final completionResult = ProfileCompletionService.compute(
          profile: currentState.profile,
          experiencesCount: updatedExperiences.length,
          completedCoursesCount: currentState.learningStats.completedCount,
          certificatesCount: currentState.certificates.length,
        );

        emit(currentState.copyWith(
          experiences: updatedExperiences,
          completionResult: completionResult,
        ));
      } catch (e) {
        emit(ProfileError(e.toString()));
        emit(currentState);
      }
    }
  }
}
