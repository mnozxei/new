import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ad_entity.dart';

abstract class AdRepository {
  Future<Either<Failure, List<AdEntity>>> getAdsForPlacement({
    required AdPlacement placement,
    int limit = 5,
  });

  Future<Either<Failure, AdEntity>> getAdById(String adId);

  Future<Either<Failure, void>> recordImpression({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, void>> recordClick({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, AdEntity>> createAd({
    required AdType type,
    required AdPlacement placement,
    required String title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? ctaText,
    String? ctaUrl,
    String? companyId,
    String? jobId,
    String? courseId,
    required double budget,
    required double costPerClick,
    required double costPerImpression,
    Map<String, dynamic>? targetAudience,
    required DateTime startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, AdEntity>> updateAd({
    required String adId,
    String? title,
    String? description,
    String? imageUrl,
    String? ctaText,
    String? ctaUrl,
    AdStatus? status,
    double? budget,
    Map<String, dynamic>? targetAudience,
    DateTime? endDate,
  });

  Future<Either<Failure, void>> deleteAd(String adId);

  Future<Either<Failure, List<AdEntity>>> getMyAds({
    int page = 1,
    int limit = 20,
    AdStatus? status,
  });

  Future<Either<Failure, AdCampaignStats>> getAdStats({
    required String adId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, AdFrequencyConfig>> getFrequencyConfig();

  Future<Either<Failure, int>> getTodayImpressionCount();

  Future<Either<Failure, bool>> canShowAd({
    required AdPlacement placement,
    required int currentIndex,
  });
}
