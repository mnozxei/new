import '../domain/entities/ad_entity.dart';
import '../domain/repositories/ad_repository.dart';

class AdInjectionResult<T> {
  const AdInjectionResult({
    required this.items,
    required this.adPositions,
  });

  final List<dynamic> items;
  final Map<int, AdEntity> adPositions;

  bool isAd(int index) => adPositions.containsKey(index);

  AdEntity? getAd(int index) => adPositions[index];

  T? getItem(int index) {
    if (isAd(index)) return null;

    int adjustedIndex = index;
    for (final adPosition in adPositions.keys) {
      if (adPosition < index) {
        adjustedIndex--;
      }
    }

    if (adjustedIndex >= 0 && adjustedIndex < items.length) {
      return items[adjustedIndex] as T;
    }
    return null;
  }

  int get totalCount => items.length + adPositions.length;
}

class AdInjectionService {
  AdInjectionService({required AdRepository adRepository})
      : _adRepository = adRepository;

  final AdRepository _adRepository;

  final Map<AdPlacement, List<AdEntity>> _adCache = {};
  final Map<AdPlacement, int> _adIndexes = {};
  final Set<String> _shownAdIds = {};

  Future<AdInjectionResult<T>> injectAds<T>({
    required List<T> items,
    required AdPlacement placement,
    bool forceRefresh = false,
  }) async {
    if (items.isEmpty) {
      return AdInjectionResult<T>(
        items: items,
        adPositions: {},
      );
    }

    if (forceRefresh || !_adCache.containsKey(placement)) {
      await _refreshAdsForPlacement(placement);
    }

    final configResult = await _adRepository.getFrequencyConfig();
    final config = configResult.fold(
      (_) => const AdFrequencyConfig(),
      (config) => config,
    );

    final interval = config.getIntervalForPlacement(placement);
    final adPositions = <int, AdEntity>{};

    int adjustedIndex = 0;
    for (int i = 0; i < items.length; i++) {
      if ((i + 1) % interval == 0 && i > 0) {
        final ad = await _getNextAdForPlacement(placement);
        if (ad != null) {
          final adPosition = adjustedIndex + (adPositions.length + 1);
          adPositions[adPosition] = ad;
        }
      }
      adjustedIndex++;
    }

    return AdInjectionResult<T>(
      items: items,
      adPositions: adPositions,
    );
  }

  Future<void> _refreshAdsForPlacement(AdPlacement placement) async {
    final result = await _adRepository.getAdsForPlacement(
      placement: placement,
      limit: 10,
    );

    result.fold(
      (_) => null,
      (ads) {
        _adCache[placement] = ads.where((ad) => !_shownAdIds.contains(ad.id)).toList();
        _adIndexes[placement] = 0;
      },
    );
  }

  Future<AdEntity?> _getNextAdForPlacement(AdPlacement placement) async {
    final ads = _adCache[placement];
    if (ads == null || ads.isEmpty) {
      await _refreshAdsForPlacement(placement);
    }

    final refreshedAds = _adCache[placement];
    if (refreshedAds == null || refreshedAds.isEmpty) {
      return null;
    }

    final currentIndex = _adIndexes[placement] ?? 0;

    if (currentIndex >= refreshedAds.length) {
      _shownAdIds.clear();
      await _refreshAdsForPlacement(placement);
      _adIndexes[placement] = 0;

      final newAds = _adCache[placement];
      if (newAds == null || newAds.isEmpty) {
        return null;
      }
    }

    final ad = _adCache[placement]![_adIndexes[placement] ?? 0];
    _adIndexes[placement] = (_adIndexes[placement] ?? 0) + 1;
    _shownAdIds.add(ad.id);

    return ad;
  }

  Future<void> recordImpression(AdEntity ad, AdPlacement placement) async {
    await _adRepository.recordImpression(
      adId: ad.id,
      placement: placement,
    );
  }

  Future<void> recordClick(AdEntity ad, AdPlacement placement) async {
    await _adRepository.recordClick(
      adId: ad.id,
      placement: placement,
    );
  }

  void clearCache() {
    _adCache.clear();
    _adIndexes.clear();
    _shownAdIds.clear();
  }

  void clearCacheForPlacement(AdPlacement placement) {
    _adCache.remove(placement);
    _adIndexes.remove(placement);
  }
}

class MixedListItem<T> {
  const MixedListItem._({
    this.item,
    this.ad,
  });

  factory MixedListItem.content(T item) => MixedListItem._(item: item);
  factory MixedListItem.ad(AdEntity ad) => MixedListItem._(ad: ad);

  final T? item;
  final AdEntity? ad;

  bool get isAd => ad != null;
  bool get isContent => item != null;
}

extension AdInjectionResultExtension<T> on AdInjectionResult<T> {
  List<MixedListItem<T>> toMixedList() {
    final result = <MixedListItem<T>>[];

    int contentIndex = 0;
    for (int i = 0; i < totalCount; i++) {
      if (isAd(i)) {
        result.add(MixedListItem<T>.ad(adPositions[i]!));
      } else {
        if (contentIndex < items.length) {
          result.add(MixedListItem<T>.content(items[contentIndex] as T));
          contentIndex++;
        }
      }
    }

    return result;
  }
}
