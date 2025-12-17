import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final profile = await _getUserProfile(event.userId);

      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('Profile not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
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
        emit(ProfileLoaded(updatedProfile));
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
          emit(ProfileLoaded(profile));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }
}
