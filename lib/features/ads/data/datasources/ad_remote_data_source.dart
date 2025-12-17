import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/ad_entity.dart';

abstract class AdRemoteDataSource {
  Future<List<AdEntity>> getAdsForPlacement({required AdPlacement placement, int limit = 5});
  Future<AdEntity> getAdById(String adId);
  Future<void> recordImpression({required String adId, required AdPlacement placement, Map<String, dynamic>? metadata});
  Future<void> recordClick({required String adId, required AdPlacement placement, Map<String, dynamic>? metadata});
  Future<AdEntity> createAd({required AdType type, required AdPlacement placement, required String title, String? description, String? imageUrl, String? videoUrl, String? ctaText, String? ctaUrl, String? companyId, String? jobId, String? courseId, required double budget, required double costPerClick, required double costPerImpression, Map<String, dynamic>? targetAudience, required DateTime startDate, DateTime? endDate});
  Future<AdEntity> updateAd({required String adId, String? title, String? description, String? imageUrl, String? ctaText, String? ctaUrl, AdStatus? status, double? budget, Map<String, dynamic>? targetAudience, DateTime? endDate});
  Future<void> deleteAd(String adId);
  Future<List<AdEntity>> getMyAds({int page = 1, int limit = 20, AdStatus? status});
  Future<AdCampaignStats> getAdStats({required String adId, DateTime? startDate, DateTime? endDate});
  Future<int> getTodayImpressionCount();
}

class AdRemoteDataSourceImpl implements AdRemoteDataSource {
  AdRemoteDataSourceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<List<AdEntity>> getAdsForPlacement({
    required AdPlacement placement,
    int limit = 5,
  }) async {
    final now = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('ads')
        .select('''
          *,
          advertiser:profiles!advertiser_id(*),
          company:companies!company_id(*)
        ''')
        .eq('status', AdStatus.active.value)
        .eq('placement', placement.value)
        .lte('start_date', now)
        .or('end_date.is.null,end_date.gte.$now')
        .gt('budget', _supabase.rpc('get_ad_spent', params: {}))
        .order('priority', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => _mapAdFromJson(json)).toList();
  }

  @override
  Future<AdEntity> getAdById(String adId) async {
    final response = await _supabase
        .from('ads')
        .select('''
          *,
          advertiser:profiles!advertiser_id(*),
          company:companies!company_id(*)
        ''')
        .eq('id', adId)
        .single();

    return _mapAdFromJson(response);
  }

  @override
  Future<void> recordImpression({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  }) async {
    await _supabase.from('ad_impressions').insert({
      'ad_id': adId,
      'user_id': _currentUserId,
      'placement': placement.value,
      'metadata': metadata ?? {},
    });

    await _supabase.rpc('increment_ad_impressions', params: {'p_ad_id': adId});
  }

  @override
  Future<void> recordClick({
    required String adId,
    required AdPlacement placement,
    Map<String, dynamic>? metadata,
  }) async {
    await _supabase.from('ad_clicks').insert({
      'ad_id': adId,
      'user_id': _currentUserId,
      'placement': placement.value,
      'metadata': metadata ?? {},
    });

    await _supabase.rpc('increment_ad_clicks', params: {'p_ad_id': adId});
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
    final response = await _supabase
        .from('ads')
        .insert({
          'advertiser_id': _currentUserId,
          'type': type.value,
          'placement': placement.value,
          'title': title,
          'description': description,
          'image_url': imageUrl,
          'video_url': videoUrl,
          'cta_text': ctaText,
          'cta_url': ctaUrl,
          'company_id': companyId,
          'job_id': jobId,
          'course_id': courseId,
          'status': AdStatus.pending.value,
          'budget': budget,
          'cost_per_click': costPerClick,
          'cost_per_impression': costPerImpression,
          'target_audience': targetAudience ?? {},
          'start_date': startDate.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
        })
        .select('''
          *,
          advertiser:profiles!advertiser_id(*),
          company:companies!company_id(*)
        ''')
        .single();

    return _mapAdFromJson(response);
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
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (imageUrl != null) updateData['image_url'] = imageUrl;
    if (ctaText != null) updateData['cta_text'] = ctaText;
    if (ctaUrl != null) updateData['cta_url'] = ctaUrl;
    if (status != null) updateData['status'] = status.value;
    if (budget != null) updateData['budget'] = budget;
    if (targetAudience != null) updateData['target_audience'] = targetAudience;
    if (endDate != null) updateData['end_date'] = endDate.toIso8601String();

    final response = await _supabase
        .from('ads')
        .update(updateData)
        .eq('id', adId)
        .select('''
          *,
          advertiser:profiles!advertiser_id(*),
          company:companies!company_id(*)
        ''')
        .single();

    return _mapAdFromJson(response);
  }

  @override
  Future<void> deleteAd(String adId) async {
    await _supabase.from('ads').delete().eq('id', adId);
  }

  @override
  Future<List<AdEntity>> getMyAds({
    int page = 1,
    int limit = 20,
    AdStatus? status,
  }) async {
    final offset = (page - 1) * limit;

    var query = _supabase
        .from('ads')
        .select('''
          *,
          advertiser:profiles!advertiser_id(*),
          company:companies!company_id(*)
        ''')
        .eq('advertiser_id', _currentUserId);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapAdFromJson(json)).toList();
  }

  @override
  Future<AdCampaignStats> getAdStats({
    required String adId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final impressionsResponse = await _supabase
        .from('ad_impressions')
        .select()
        .eq('ad_id', adId)
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    final clicksResponse = await _supabase
        .from('ad_clicks')
        .select()
        .eq('ad_id', adId)
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    final adResponse = await _supabase
        .from('ads')
        .select()
        .eq('id', adId)
        .single();

    final impressions = impressionsResponse as List;
    final clicks = clicksResponse as List;
    final ad = adResponse;

    final totalImpressions = impressions.length;
    final totalClicks = clicks.length;
    final costPerClick = (ad['cost_per_click'] as num?)?.toDouble() ?? 0;
    final costPerImpression = (ad['cost_per_impression'] as num?)?.toDouble() ?? 0;
    final totalSpent = (totalClicks * costPerClick) + (totalImpressions * costPerImpression / 1000);

    final dailyStatsMap = <String, DailyAdStats>{};

    for (final impression in impressions) {
      final date = DateTime.parse(impression['created_at'] as String);
      final dateKey = '${date.year}-${date.month}-${date.day}';

      if (!dailyStatsMap.containsKey(dateKey)) {
        dailyStatsMap[dateKey] = DailyAdStats(
          date: DateTime(date.year, date.month, date.day),
          impressions: 0,
          clicks: 0,
          spent: 0,
        );
      }

      final existing = dailyStatsMap[dateKey]!;
      dailyStatsMap[dateKey] = DailyAdStats(
        date: existing.date,
        impressions: existing.impressions + 1,
        clicks: existing.clicks,
        spent: existing.spent + (costPerImpression / 1000),
      );
    }

    for (final click in clicks) {
      final date = DateTime.parse(click['created_at'] as String);
      final dateKey = '${date.year}-${date.month}-${date.day}';

      if (!dailyStatsMap.containsKey(dateKey)) {
        dailyStatsMap[dateKey] = DailyAdStats(
          date: DateTime(date.year, date.month, date.day),
          impressions: 0,
          clicks: 0,
          spent: 0,
        );
      }

      final existing = dailyStatsMap[dateKey]!;
      dailyStatsMap[dateKey] = DailyAdStats(
        date: existing.date,
        impressions: existing.impressions,
        clicks: existing.clicks + 1,
        spent: existing.spent + costPerClick,
      );
    }

    final dailyStats = dailyStatsMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return AdCampaignStats(
      adId: adId,
      totalImpressions: totalImpressions,
      totalClicks: totalClicks,
      totalSpent: totalSpent,
      ctr: totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0,
      averageCpc: totalClicks > 0 ? (totalClicks * costPerClick) / totalClicks : costPerClick,
      averageCpm: costPerImpression,
      dailyStats: dailyStats,
    );
  }

  @override
  Future<int> getTodayImpressionCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final response = await _supabase
        .from('ad_impressions')
        .select()
        .eq('user_id', _currentUserId)
        .gte('created_at', startOfDay.toIso8601String())
        .count(CountOption.exact);

    return response.count;
  }

  AdEntity _mapAdFromJson(Map<String, dynamic> json) {
    return AdEntity(
      id: json['id'] as String,
      advertiserId: json['advertiser_id'] as String,
      type: AdType.fromString(json['type'] as String),
      placement: AdPlacement.fromString(json['placement'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      ctaText: json['cta_text'] as String?,
      ctaUrl: json['cta_url'] as String?,
      companyId: json['company_id'] as String?,
      jobId: json['job_id'] as String?,
      courseId: json['course_id'] as String?,
      status: AdStatus.fromString(json['status'] as String),
      impressionsCount: json['impressions_count'] as int? ?? 0,
      clicksCount: json['clicks_count'] as int? ?? 0,
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
      costPerClick: (json['cost_per_click'] as num?)?.toDouble() ?? 0,
      costPerImpression: (json['cost_per_impression'] as num?)?.toDouble() ?? 0,
      targetAudience: Map<String, dynamic>.from(json['target_audience'] ?? {}),
      priority: json['priority'] as int? ?? 0,
      advertiserName: json['advertiser']?['full_name'] as String?,
      advertiserLogo: json['advertiser']?['avatar_url'] as String?,
      companyName: json['company']?['name'] as String?,
      companyLogo: json['company']?['logo_url'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
