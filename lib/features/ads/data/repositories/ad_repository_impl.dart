import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';
import '../datasources/ad_remote_data_source.dart';

class AdRepositoryImpl implements AdRepository {
  AdRepositoryImpl({required AdRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AdRemoteDataSource _remoteDataSource;

  final AdFrequencyConfig _frequencyConfig = const AdFrequencyConfig();
  int _sessionImpressionCount = 0;
  DateTime? _lastAdShownTime;

  @override
  Future<Either<Failure, List<AdEntity>>> getAdsForPlacement({
    required AdPlacement placement,
    int limit = 5,
  }) async {
    try {
      final ads = await _remoteDataSource.getAdsForPlacement(
        placement: placement,
        limit: limit,
      );
      return Right(ads);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdEntity>> getAdById(String adId) async {
    try {
      final ad = await _remoteDataSource.getAdById(adId);
      return Right(ad);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordImpression({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _remoteDataSource.recordImpression(
        adId: adId,
        placement: placement,
        metadata: metadata,
      );
      _sessionImpressionCount++;
      _lastAdShownTime = DateTime.now();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordClick({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _remoteDataSource.recordClick(
        adId: adId,
        placement: placement,
        metadata: metadata,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final ad = await _remoteDataSource.createAd(
        type: type,
        placement: placement,
        title: title,
        description: description,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        ctaText: ctaText,
        ctaUrl: ctaUrl,
        companyId: companyId,
        jobId: jobId,
        courseId: courseId,
        budget: budget,
        costPerClick: costPerClick,
        costPerImpression: costPerImpression,
        targetAudience: targetAudience,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(ad);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final ad = await _remoteDataSource.updateAd(
        adId: adId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        ctaText: ctaText,
        ctaUrl: ctaUrl,
        status: status,
        budget: budget,
        targetAudience: targetAudience,
        endDate: endDate,
      );
      return Right(ad);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAd(String adId) async {
    try {
      await _remoteDataSource.deleteAd(adId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdEntity>>> getMyAds({
    int page = 1,
    int limit = 20,
    AdStatus? status,
  }) async {
    try {
      final ads = await _remoteDataSource.getMyAds(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(ads);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdCampaignStats>> getAdStats({
    required String adId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await _remoteDataSource.getAdStats(
        adId: adId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdFrequencyConfig>> getFrequencyConfig() async {
    return Right(_frequencyConfig);
  }

  @override
  Future<Either<Failure, int>> getTodayImpressionCount() async {
    try {
      final count = await _remoteDataSource.getTodayImpressionCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canShowAd({
    required AdPlacement placement,
    required int currentIndex,
  }) async {
    try {
      if (_sessionImpressionCount >= _frequencyConfig.maxAdsPerSession) {
        return const Right(false);
      }

      if (_lastAdShownTime != null) {
        final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
        if (timeSinceLastAd < _frequencyConfig.minTimeBetweenAds) {
          return const Right(false);
        }
      }

      final todayCount = await _remoteDataSource.getTodayImpressionCount();
      if (todayCount >= _frequencyConfig.dailyImpressionCap) {
        return const Right(false);
      }

      final interval = _frequencyConfig.getIntervalForPlacement(placement);
      final shouldShowAd = currentIndex > 0 && (currentIndex + 1) % interval == 0;

      return Right(shouldShowAd);
    } catch (e) {
      return const Right(false);
    }
  }
}
