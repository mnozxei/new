import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';

part 'ad_event.dart';
part 'ad_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  AdBloc({required AdRepository adRepository})
      : _adRepository = adRepository,
        super(const AdInitial()) {
    on<LoadAdsForPlacement>(_onLoadAdsForPlacement);
    on<LoadAdDetails>(_onLoadAdDetails);
    on<RecordAdImpression>(_onRecordAdImpression);
    on<RecordAdClick>(_onRecordAdClick);
    on<CreateAd>(_onCreateAd);
    on<UpdateAd>(_onUpdateAd);
    on<DeleteAd>(_onDeleteAd);
    on<LoadMyAds>(_onLoadMyAds);
    on<LoadAdStats>(_onLoadAdStats);
    on<CheckCanShowAd>(_onCheckCanShowAd);
  }

  final AdRepository _adRepository;

  Future<void> _onLoadAdsForPlacement(LoadAdsForPlacement event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    final result = await _adRepository.getAdsForPlacement(
      placement: event.placement,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(AdError(message: failure.message)),
      (ads) => emit(AdsLoaded(
        placement: event.placement,
        ads: ads,
      )),
    );
  }

  Future<void> _onLoadAdDetails(LoadAdDetails event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    final result = await _adRepository.getAdById(event.adId);

    result.fold(
      (failure) => emit(AdError(message: failure.message)),
      (ad) => emit(AdDetailsLoaded(ad: ad)),
    );
  }

  Future<void> _onRecordAdImpression(RecordAdImpression event, Emitter<AdState> emit) async {
    await _adRepository.recordImpression(
      adId: event.adId,
      placement: event.placement,
      metadata: event.metadata,
    );
  }

  Future<void> _onRecordAdClick(RecordAdClick event, Emitter<AdState> emit) async {
    await _adRepository.recordClick(
      adId: event.adId,
      placement: event.placement,
      metadata: event.metadata,
    );

    emit(AdClicked(adId: event.adId));
  }

  Future<void> _onCreateAd(CreateAd event, Emitter<AdState> emit) async {
    emit(const AdCreating());

    final result = await _adRepository.createAd(
      type: event.type,
      placement: event.placement,
      title: event.title,
      description: event.description,
      imageUrl: event.imageUrl,
      videoUrl: event.videoUrl,
      ctaText: event.ctaText,
      ctaUrl: event.ctaUrl,
      companyId: event.companyId,
      jobId: event.jobId,
      courseId: event.courseId,
      budget: event.budget,
      costPerClick: event.costPerClick,
      costPerImpression: event.costPerImpression,
      targetAudience: event.targetAudience,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(AdError(message: failure.message)),
      (ad) => emit(AdCreated(ad: ad)),
    );
  }

  Future<void> _onUpdateAd(UpdateAd event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    final result = await _adRepository.updateAd(
      adId: event.adId,
      title: event.title,
      description: event.description,
      imageUrl: event.imageUrl,
      ctaText: event.ctaText,
      ctaUrl: event.ctaUrl,
      status: event.status,
      budget: event.budget,
      targetAudience: event.targetAudience,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(AdError(message: failure.message)),
      (ad) => emit(AdUpdated(ad: ad)),
    );
  }

  Future<void> _onDeleteAd(DeleteAd event, Emitter<AdState> emit) async {
    final result = await _adRepository.deleteAd(event.adId);

    result.fold(
      (failure) => emit(AdError(message: failure.message)),
      (_) => emit(AdDeleted(adId: event.adId)),
    );
  }

  Future<void> _onLoadMyAds(LoadMyAds event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    final result = await _adRepository.getMyAds(
      page: event.page,
      limit: event.limit,
      status: event.status,
    );

    result.fold(
      (failure) => emit(AdError(message: failure.message)),
      (ads) => emit(MyAdsLoaded(
        ads: ads,
        hasMore: ads.length >= event.limit,
      )),
    );
  }

  Future<void> _onLoadAdStats(LoadAdStats event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    final result = await _adRepository.getAdStats(
      adId: event.adId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(AdError(message: failure.message)),
      (stats) => emit(AdStatsLoaded(stats: stats)),
    );
  }

  Future<void> _onCheckCanShowAd(CheckCanShowAd event, Emitter<AdState> emit) async {
    final result = await _adRepository.canShowAd(
      placement: event.placement,
      currentIndex: event.currentIndex,
    );

    result.fold(
      (failure) => emit(const CanShowAdResult(canShow: false)),
      (canShow) => emit(CanShowAdResult(canShow: canShow)),
    );
  }
}
