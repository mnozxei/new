import 'package:equatable/equatable.dart';

enum AdType {
  native('native', 'إعلان محلي'),
  banner('banner', 'بانر'),
  interstitial('interstitial', 'إعلان بيني'),
  sponsored('sponsored', 'محتوى مدعوم');

  const AdType(this.value, this.label);
  final String value;
  final String label;

  static AdType fromString(String value) {
    return AdType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AdType.native,
    );
  }
}

enum AdPlacement {
  feed('feed', 'الخلاصة'),
  jobsList('jobs_list', 'قائمة الوظائف'),
  coursesList('courses_list', 'قائمة الدورات'),
  chatList('chat_list', 'قائمة المحادثات'),
  companyProfile('company_profile', 'صفحة الشركة'),
  searchResults('search_results', 'نتائج البحث');

  const AdPlacement(this.value, this.label);
  final String value;
  final String label;

  static AdPlacement fromString(String value) {
    return AdPlacement.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AdPlacement.feed,
    );
  }
}

enum AdStatus {
  active('active', 'نشط'),
  paused('paused', 'متوقف'),
  ended('ended', 'منتهي'),
  pending('pending', 'قيد المراجعة'),
  rejected('rejected', 'مرفوض');

  const AdStatus(this.value, this.label);
  final String value;
  final String label;

  static AdStatus fromString(String value) {
    return AdStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AdStatus.pending,
    );
  }
}

class AdEntity extends Equatable {
  const AdEntity({
    required this.id,
    required this.advertiserId,
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
    required this.status,
    this.impressionsCount = 0,
    this.clicksCount = 0,
    this.budget = 0,
    this.spent = 0,
    this.costPerClick = 0,
    this.costPerImpression = 0,
    this.targetAudience = const {},
    this.priority = 0,
    this.advertiserName,
    this.advertiserLogo,
    this.companyName,
    this.companyLogo,
    required this.startDate,
    this.endDate,
    required this.createdAt,
  });

  final String id;
  final String advertiserId;
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
  final AdStatus status;
  final int impressionsCount;
  final int clicksCount;
  final double budget;
  final double spent;
  final double costPerClick;
  final double costPerImpression;
  final Map<String, dynamic> targetAudience;
  final int priority;
  final String? advertiserName;
  final String? advertiserLogo;
  final String? companyName;
  final String? companyLogo;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  double get ctr => impressionsCount > 0 ? (clicksCount / impressionsCount) * 100 : 0;

  double get remainingBudget => budget - spent;

  bool get isActive =>
      status == AdStatus.active &&
      DateTime.now().isAfter(startDate) &&
      (endDate == null || DateTime.now().isBefore(endDate!)) &&
      remainingBudget > 0;

  AdEntity copyWith({
    String? id,
    String? advertiserId,
    AdType? type,
    AdPlacement? placement,
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? ctaText,
    String? ctaUrl,
    String? companyId,
    String? jobId,
    String? courseId,
    AdStatus? status,
    int? impressionsCount,
    int? clicksCount,
    double? budget,
    double? spent,
    double? costPerClick,
    double? costPerImpression,
    Map<String, dynamic>? targetAudience,
    int? priority,
    String? advertiserName,
    String? advertiserLogo,
    String? companyName,
    String? companyLogo,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return AdEntity(
      id: id ?? this.id,
      advertiserId: advertiserId ?? this.advertiserId,
      type: type ?? this.type,
      placement: placement ?? this.placement,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      ctaText: ctaText ?? this.ctaText,
      ctaUrl: ctaUrl ?? this.ctaUrl,
      companyId: companyId ?? this.companyId,
      jobId: jobId ?? this.jobId,
      courseId: courseId ?? this.courseId,
      status: status ?? this.status,
      impressionsCount: impressionsCount ?? this.impressionsCount,
      clicksCount: clicksCount ?? this.clicksCount,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      costPerClick: costPerClick ?? this.costPerClick,
      costPerImpression: costPerImpression ?? this.costPerImpression,
      targetAudience: targetAudience ?? this.targetAudience,
      priority: priority ?? this.priority,
      advertiserName: advertiserName ?? this.advertiserName,
      advertiserLogo: advertiserLogo ?? this.advertiserLogo,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        advertiserId,
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
        status,
        impressionsCount,
        clicksCount,
        budget,
        spent,
        costPerClick,
        costPerImpression,
        targetAudience,
        priority,
        startDate,
        endDate,
        createdAt,
      ];
}

class AdImpression extends Equatable {
  const AdImpression({
    required this.id,
    required this.adId,
    required this.userId,
    required this.placement,
    this.metadata = const {},
    required this.timestamp,
  });

  final String id;
  final String adId;
  final String userId;
  final AdPlacement placement;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, adId, userId, placement, metadata, timestamp];
}

class AdClick extends Equatable {
  const AdClick({
    required this.id,
    required this.adId,
    required this.userId,
    required this.placement,
    this.metadata = const {},
    required this.timestamp,
  });

  final String id;
  final String adId;
  final String userId;
  final AdPlacement placement;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, adId, userId, placement, metadata, timestamp];
}

class AdFrequencyConfig extends Equatable {
  const AdFrequencyConfig({
    this.feedInterval = 5,
    this.jobsListInterval = 4,
    this.coursesListInterval = 4,
    this.chatListInterval = 6,
    this.maxAdsPerSession = 20,
    this.minTimeBetweenAds = const Duration(seconds: 30),
    this.dailyImpressionCap = 100,
  });

  final int feedInterval;
  final int jobsListInterval;
  final int coursesListInterval;
  final int chatListInterval;
  final int maxAdsPerSession;
  final Duration minTimeBetweenAds;
  final int dailyImpressionCap;

  int getIntervalForPlacement(AdPlacement placement) {
    switch (placement) {
      case AdPlacement.feed:
        return feedInterval;
      case AdPlacement.jobsList:
        return jobsListInterval;
      case AdPlacement.coursesList:
        return coursesListInterval;
      case AdPlacement.chatList:
        return chatListInterval;
      default:
        return feedInterval;
    }
  }

  @override
  List<Object?> get props => [
        feedInterval,
        jobsListInterval,
        coursesListInterval,
        chatListInterval,
        maxAdsPerSession,
        minTimeBetweenAds,
        dailyImpressionCap,
      ];
}

class AdCampaignStats extends Equatable {
  const AdCampaignStats({
    required this.adId,
    required this.totalImpressions,
    required this.totalClicks,
    required this.totalSpent,
    required this.ctr,
    required this.averageCpc,
    required this.averageCpm,
    required this.dailyStats,
  });

  final String adId;
  final int totalImpressions;
  final int totalClicks;
  final double totalSpent;
  final double ctr;
  final double averageCpc;
  final double averageCpm;
  final List<DailyAdStats> dailyStats;

  @override
  List<Object?> get props => [
        adId,
        totalImpressions,
        totalClicks,
        totalSpent,
        ctr,
        averageCpc,
        averageCpm,
        dailyStats,
      ];
}

class DailyAdStats extends Equatable {
  const DailyAdStats({
    required this.date,
    required this.impressions,
    required this.clicks,
    required this.spent,
  });

  final DateTime date;
  final int impressions;
  final int clicks;
  final double spent;

  double get ctr => impressions > 0 ? (clicks / impressions) * 100 : 0;

  @override
  List<Object?> get props => [date, impressions, clicks, spent];
}
