part of 'ad_bloc.dart';

abstract class AdEvent extends Equatable {
  const AdEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdsForPlacement extends AdEvent {
  const LoadAdsForPlacement({
    required this.placement,
    this.limit = 5,
  });

  final AdPlacement placement;
  final int limit;

  @override
  List<Object?> get props => [placement, limit];
}

class LoadAdDetails extends AdEvent {
  const LoadAdDetails({required this.adId});

  final String adId;

  @override
  List<Object?> get props => [adId];
}

class RecordAdImpression extends AdEvent {
  const RecordAdImpression({
    required this.adId,
    required this.placement,
    this.metadata,
  });

  final String adId;
  final AdPlacement placement;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [adId, placement, metadata];
}

class RecordAdClick extends AdEvent {
  const RecordAdClick({
    required this.adId,
    required this.placement,
    this.metadata,
  });

  final String adId;
  final AdPlacement placement;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [adId, placement, metadata];
}

class CreateAd extends AdEvent {
  const CreateAd({
    required this.type,
    required this.placement,
    required this.title,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.ctaText,
    this.ctaUrl,
    this.companyId,
    this.jobId,
    this.courseId,
    required this.budget,
    required this.costPerClick,
    required this.costPerImpression,
    this.targetAudience,
    required this.startDate,
    this.endDate,
  });

  final AdType type;
  final AdPlacement placement;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final String? ctaText;
  final String? ctaUrl;
  final String? companyId;
  final String? jobId;
  final String? courseId;
  final double budget;
  final double costPerClick;
  final double costPerImpression;
  final Map<String, dynamic>? targetAudience;
  final DateTime startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [
        type,
        placement,
        title,
        description,
        imageUrl,
        videoUrl,
        ctaText,
        ctaUrl,
        companyId,
        jobId,
        courseId,
        budget,
        costPerClick,
        costPerImpression,
        targetAudience,
        startDate,
        endDate,
      ];
}

class UpdateAd extends AdEvent {
  const UpdateAd({
    required this.adId,
    this.title,
    this.description,
    this.imageUrl,
    this.ctaText,
    this.ctaUrl,
    this.status,
    this.budget,
    this.targetAudience,
    this.endDate,
  });

  final String adId;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? ctaText;
  final String? ctaUrl;
  final AdStatus? status;
  final double? budget;
  final Map<String, dynamic>? targetAudience;
  final DateTime? endDate;

  @override
  List<Object?> get props => [
        adId,
        title,
        description,
        imageUrl,
        ctaText,
        ctaUrl,
        status,
        budget,
        targetAudience,
        endDate,
      ];
}

class DeleteAd extends AdEvent {
  const DeleteAd({required this.adId});

  final String adId;

  @override
  List<Object?> get props => [adId];
}

class LoadMyAds extends AdEvent {
  const LoadMyAds({
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  final int page;
  final int limit;
  final AdStatus? status;

  @override
  List<Object?> get props => [page, limit, status];
}

class LoadAdStats extends AdEvent {
  const LoadAdStats({
    required this.adId,
    this.startDate,
    this.endDate,
  });

  final String adId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [adId, startDate, endDate];
}

class CheckCanShowAd extends AdEvent {
  const CheckCanShowAd({
    required this.placement,
    required this.currentIndex,
  });

  final AdPlacement placement;
  final int currentIndex;

  @override
  List<Object?> get props => [placement, currentIndex];
}
