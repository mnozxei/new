import 'package:supabase_flutter/supabase_flutter.dart';

/// Entity types that can have impressions tracked
enum ImpressionEntityType {
  post('post'),
  job('job'),
  course('course'),
  company('company'),
  profile('profile');

  const ImpressionEntityType(this.value);
  final String value;
}

/// Service for tracking content impressions/views
class ImpressionsService {
  ImpressionsService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // Cache to prevent duplicate impressions within session
  final Set<String> _recordedImpressions = {};

  /// Record an impression for an entity
  /// Debounced to prevent duplicate tracking within session
  Future<void> recordImpression({
    required ImpressionEntityType entityType,
    required String entityId,
  }) async {
    final key = '${entityType.value}:$entityId';

    // Skip if already recorded this session
    if (_recordedImpressions.contains(key)) {
      return;
    }

    try {
      final userId = _client.auth.currentUser?.id;
      final dateBucket = DateTime.now().toIso8601String().substring(0, 10);

      await _client.rpc('record_impression', params: {
        'p_entity_type': entityType.value,
        'p_entity_id': entityId,
        'p_viewer_user_id': userId,
        'p_date_bucket': dateBucket,
      });

      _recordedImpressions.add(key);
    } catch (e) {
      // Silently fail - impressions are non-critical
      // print('Failed to record impression: $e');
    }
  }

  /// Get impression stats for an entity
  Future<ImpressionStats> getStats({
    required ImpressionEntityType entityType,
    required String entityId,
  }) async {
    try {
      final response = await _client.rpc('get_impression_stats', params: {
        'p_entity_type': entityType.value,
        'p_entity_id': entityId,
      });

      if (response != null && response is Map) {
        return ImpressionStats.fromJson(response as Map<String, dynamic>);
      }
    } catch (e) {
      // Return empty stats on error
    }

    return const ImpressionStats();
  }

  /// Get aggregated stats for multiple entities (for dashboards)
  Future<List<EntityImpressionStats>> getAggregatedStats({
    required ImpressionEntityType entityType,
    required List<String> entityIds,
    int? days,
  }) async {
    try {
      final response = await _client.rpc('get_aggregated_impression_stats', params: {
        'p_entity_type': entityType.value,
        'p_entity_ids': entityIds,
        'p_days': days ?? 30,
      });

      if (response != null && response is List) {
        return response
            .map((e) => EntityImpressionStats.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Return empty list on error
    }

    return [];
  }

  /// Get trending entities by impressions
  Future<List<TrendingEntity>> getTrending({
    required ImpressionEntityType entityType,
    int limit = 10,
    int days = 7,
  }) async {
    try {
      final response = await _client.rpc('get_trending_by_impressions', params: {
        'p_entity_type': entityType.value,
        'p_limit': limit,
        'p_days': days,
      });

      if (response != null && response is List) {
        return response
            .map((e) => TrendingEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Return empty list on error
    }

    return [];
  }

  /// Clear session cache (call on logout)
  void clearCache() {
    _recordedImpressions.clear();
  }
}

/// Stats for a single entity
class ImpressionStats {
  const ImpressionStats({
    this.totalViews = 0,
    this.uniqueViews = 0,
    this.todayViews = 0,
    this.weekViews = 0,
    this.monthViews = 0,
  });

  final int totalViews;
  final int uniqueViews;
  final int todayViews;
  final int weekViews;
  final int monthViews;

  factory ImpressionStats.fromJson(Map<String, dynamic> json) {
    return ImpressionStats(
      totalViews: json['total_views'] as int? ?? 0,
      uniqueViews: json['unique_views'] as int? ?? 0,
      todayViews: json['today_views'] as int? ?? 0,
      weekViews: json['week_views'] as int? ?? 0,
      monthViews: json['month_views'] as int? ?? 0,
    );
  }
}

/// Stats for entity in aggregated list
class EntityImpressionStats {
  const EntityImpressionStats({
    required this.entityId,
    this.totalViews = 0,
    this.uniqueViews = 0,
    this.dailyStats = const [],
  });

  final String entityId;
  final int totalViews;
  final int uniqueViews;
  final List<DailyImpressionStats> dailyStats;

  factory EntityImpressionStats.fromJson(Map<String, dynamic> json) {
    return EntityImpressionStats(
      entityId: json['entity_id'] as String,
      totalViews: json['total_views'] as int? ?? 0,
      uniqueViews: json['unique_views'] as int? ?? 0,
      dailyStats: (json['daily_stats'] as List<dynamic>?)
              ?.map((e) => DailyImpressionStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Daily breakdown of impressions
class DailyImpressionStats {
  const DailyImpressionStats({
    required this.date,
    this.views = 0,
    this.uniqueViews = 0,
  });

  final DateTime date;
  final int views;
  final int uniqueViews;

  factory DailyImpressionStats.fromJson(Map<String, dynamic> json) {
    return DailyImpressionStats(
      date: DateTime.parse(json['date'] as String),
      views: json['views'] as int? ?? 0,
      uniqueViews: json['unique_views'] as int? ?? 0,
    );
  }
}

/// Trending entity data
class TrendingEntity {
  const TrendingEntity({
    required this.entityId,
    this.viewCount = 0,
    this.growthRate = 0.0,
  });

  final String entityId;
  final int viewCount;
  final double growthRate;

  factory TrendingEntity.fromJson(Map<String, dynamic> json) {
    return TrendingEntity(
      entityId: json['entity_id'] as String,
      viewCount: json['view_count'] as int? ?? 0,
      growthRate: (json['growth_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
