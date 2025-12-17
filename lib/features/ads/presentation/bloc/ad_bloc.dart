import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';

part 'ad_event.dart';
part 'ad_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  AdBloc({required this.repository}) : super(const AdInitial()) {
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

  final AdRepository repository;

  Future<void> _onLoadAdsForPlacement(LoadAdsForPlacement event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    try {
      final ads = await repository.getAdsForPlacement(
        placement: event.placement,
        limit: event.limit,
      );
      emit(AdsLoaded(
        placement: event.placement,
        ads: ads,
      ));
    } catch (e) {
      emit(AdError(message: e.toString()));
    }
  }

  Future<void> _onLoadAdDetails(LoadAdDetails event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    try {
      final ad = await repository.getAdById(event.adId);
      if (ad == null) {
        emit(const AdError(message: 'Ad not found'));
        return;
      }
      emit(AdDetailsLoaded(ad: ad));
    } catch (e) {
      emit(AdError(message: e.toString()));
    }
  }

  Future<void> _onRecordAdImpression(RecordAdImpression event, Emitter<AdState> emit) async {
    await repository.recordImpression(
      adId: event.adId,
      placement: event.placement,
      metadata: event.metadata,
    );
  }

  Future<void> _onRecordAdClick(RecordAdClick event, Emitter<AdState> emit) async {
    await repository.recordClick(
      adId: event.adId,
      placement: event.placement,
      metadata: event.metadata,
    );
    emit(AdClicked(adId: event.adId));
  }

  Future<void> _onCreateAd(CreateAd event, Emitter<AdState> emit) async {
    emit(const AdCreating());

    try {
      final ad = await repository.createAd(
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
      emit(AdCreated(ad: ad));
    } catch (e) {
      emit(AdError(message: e.toString()));
    }
  }

  Future<void> _onUpdateAd(UpdateAd event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    try {
      final ad = await repository.updateAd(
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
      emit(AdUpdated(ad: ad));
    } catch (e) {
      emit(AdError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAd(DeleteAd event, Emitter<AdState> emit) async {
    try {
      await repository.deleteAd(event.adId);
      emit(AdDeleted(adId: event.adId));
    } catch (e) {
      emit(AdError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyAds(LoadMyAds event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    try {
      final ads = await repository.getMyAds(
        limit: event.limit,
        offset: (event.page - 1) * event.limit,
        status: event.status,
      );
      emit(MyAdsLoaded(
        ads: ads,
        hasMore: ads.length >= event.limit,
      ));
    } catch (e) {
      emit(AdError(message: e.toString()));
    }
  }

  Future<void> _onLoadAdStats(LoadAdStats event, Emitter<AdState> emit) async {
    emit(const AdLoading());

    try {
      final stats = await repository.getAdStats(
        adId: event.adId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(AdStatsLoaded(stats: stats));
    } catch (e) {
      emit(AdError(message: e.toString()));
    }
  }

  Future<void> _onCheckCanShowAd(CheckCanShowAd event, Emitter<AdState> emit) async {
    try {
      final canShow = await repository.canShowAd(
        placement: event.placement,
        currentIndex: event.currentIndex,
      );
      emit(CanShowAdResult(canShow: canShow));
    } catch (_) {
      emit(const CanShowAdResult(canShow: false));
    }
  }
}
