part of 'ad_bloc.dart';

abstract class AdState extends Equatable {
  const AdState();

  @override
  List<Object?> get props => [];
}

class AdInitial extends AdState {
  const AdInitial();
}

class AdLoading extends AdState {
  const AdLoading();
}

class AdCreating extends AdState {
  const AdCreating();
}

class AdError extends AdState {
  const AdError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class AdsLoaded extends AdState {
  const AdsLoaded({
    required this.placement,
    required this.ads,
  });

  final AdPlacement placement;
  final List<AdEntity> ads;

  @override
  List<Object?> get props => [placement, ads];
}

class AdDetailsLoaded extends AdState {
  const AdDetailsLoaded({required this.ad});

  final AdEntity ad;

  @override
  List<Object?> get props => [ad];
}

class AdCreated extends AdState {
  const AdCreated({required this.ad});

  final AdEntity ad;

  @override
  List<Object?> get props => [ad];
}

class AdUpdated extends AdState {
  const AdUpdated({required this.ad});

  final AdEntity ad;

  @override
  List<Object?> get props => [ad];
}

class AdDeleted extends AdState {
  const AdDeleted({required this.adId});

  final String adId;

  @override
  List<Object?> get props => [adId];
}

class AdClicked extends AdState {
  const AdClicked({required this.adId});

  final String adId;

  @override
  List<Object?> get props => [adId];
}

class MyAdsLoaded extends AdState {
  const MyAdsLoaded({
    required this.ads,
    this.hasMore = false,
  });

  final List<AdEntity> ads;
  final bool hasMore;

  @override
  List<Object?> get props => [ads, hasMore];
}

class AdStatsLoaded extends AdState {
  const AdStatsLoaded({required this.stats});

  final AdCampaignStats stats;

  @override
  List<Object?> get props => [stats];
}

class CanShowAdResult extends AdState {
  const CanShowAdResult({required this.canShow});

  final bool canShow;

  @override
  List<Object?> get props => [canShow];
}
