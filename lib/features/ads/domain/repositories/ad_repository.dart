import '../entities/ad_entity.dart';

abstract class AdRepository {
  /// Get ads for a placement
  Future<List<AdEntity>> getAdsForPlacement({
    required AdPlacement placement,
    int limit = 5,
  });

  /// Get ad by ID
  Future<AdEntity?> getAdById(String adId);

  /// Record ad impression
  Future<void> recordImpression({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  });

  /// Record ad click
  Future<void> recordClick({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  });

  /// Create an ad
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
  });

  /// Update an ad
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
  });

  /// Delete an ad
  Future<void> deleteAd(String adId);

  /// Get my ads
  Future<List<AdEntity>> getMyAds({
    int limit = 20,
    int offset = 0,
    AdStatus? status,
  });

  /// Get ad statistics
  Future<AdCampaignStats> getAdStats({
    required String adId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get ad frequency config
  Future<AdFrequencyConfig> getFrequencyConfig();

  /// Check if can show ad at position
  Future<bool> canShowAd({
    required AdPlacement placement,
    required int currentIndex,
  });
}
