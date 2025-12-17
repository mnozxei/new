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
  Future<List<AdEntity>> getAdsForPlacement({
    required AdPlacement placement,
    int limit = 5,
  }) async {
    return _remoteDataSource.getAdsForPlacement(
      placement: placement,
      limit: limit,
    );
  }

  @override
  Future<AdEntity?> getAdById(String adId) async {
    return _remoteDataSource.getAdById(adId);
  }

  @override
  Future<void> recordImpression({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  }) async {
    await _remoteDataSource.recordImpression(
      adId: adId,
      placement: placement,
      metadata: metadata,
    );
    _sessionImpressionCount++;
    _lastAdShownTime = DateTime.now();
  }

  @override
  Future<void> recordClick({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  }) async {
    await _remoteDataSource.recordClick(
      adId: adId,
      placement: placement,
      metadata: metadata,
    );
  }

  @override
  Future<AdEntity> createAd({
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
    return _remoteDataSource.createAd(
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
  }

  @override
  Future<AdEntity> updateAd({
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
    return _remoteDataSource.updateAd(
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
  }

  @override
  Future<void> deleteAd(String adId) async {
    await _remoteDataSource.deleteAd(adId);
  }

  @override
  Future<List<AdEntity>> getMyAds({
    int limit = 20,
    int offset = 0,
    AdStatus? status,
  }) async {
    return _remoteDataSource.getMyAds(
      limit: limit,
      offset: offset,
      status: status,
    );
  }

  @override
  Future<AdCampaignStats> getAdStats({
    required String adId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _remoteDataSource.getAdStats(
      adId: adId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<AdFrequencyConfig> getFrequencyConfig() async {
    return _frequencyConfig;
  }

  @override
  Future<bool> canShowAd({
    required AdPlacement placement,
    required int currentIndex,
  }) async {
    if (_sessionImpressionCount >= _frequencyConfig.maxAdsPerSession) {
      return false;
    }

    if (_lastAdShownTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
      if (timeSinceLastAd < _frequencyConfig.minTimeBetweenAds) {
        return false;
      }
    }

    final todayCount = await _remoteDataSource.getTodayImpressionCount();
    if (todayCount >= _frequencyConfig.dailyImpressionCap) {
      return false;
    }

    final interval = _frequencyConfig.getIntervalForPlacement(placement);
    final shouldShowAd = currentIndex > 0 && (currentIndex + 1) % interval == 0;

    return shouldShowAd;
  }
}
