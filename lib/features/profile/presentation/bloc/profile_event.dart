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
