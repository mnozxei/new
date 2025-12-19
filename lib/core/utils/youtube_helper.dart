/// YouTube video URL helper utilities
class YouTubeHelper {
  YouTubeHelper._();

  /// Regular expressions for YouTube URL patterns
  static final RegExp _youtubeRegex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=|embed\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})(?:\S*)?$',
    caseSensitive: false,
  );

  static final RegExp _youtubeShortRegex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?youtu\.be\/([a-zA-Z0-9_-]{11})(?:\S*)?$',
    caseSensitive: false,
  );

  static final RegExp _youtubeWatchRegex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]{11})(?:\S*)?$',
    caseSensitive: false,
  );

  static final RegExp _youtubeEmbedRegex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?youtube\.com\/embed\/([a-zA-Z0-9_-]{11})(?:\S*)?$',
    caseSensitive: false,
  );

  /// Check if a URL is a valid YouTube video URL
  static bool isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;
    return _youtubeRegex.hasMatch(url.trim());
  }

  /// Extract video ID from a YouTube URL
  /// Returns null if the URL is invalid
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;

    final trimmedUrl = url.trim();

    // Try each pattern
    var match = _youtubeShortRegex.firstMatch(trimmedUrl);
    if (match != null) return match.group(1);

    match = _youtubeWatchRegex.firstMatch(trimmedUrl);
    if (match != null) return match.group(1);

    match = _youtubeEmbedRegex.firstMatch(trimmedUrl);
    if (match != null) return match.group(1);

    match = _youtubeRegex.firstMatch(trimmedUrl);
    if (match != null) return match.group(1);

    return null;
  }

  /// Get the embed URL for a YouTube video
  static String? getEmbedUrl(String url) {
    final videoId = extractVideoId(url);
    if (videoId == null) return null;
    return 'https://www.youtube.com/embed/$videoId';
  }

  /// Get the thumbnail URL for a YouTube video
  /// Quality options: default, mqdefault, hqdefault, sddefault, maxresdefault
  static String? getThumbnailUrl(String url, {String quality = 'hqdefault'}) {
    final videoId = extractVideoId(url);
    if (videoId == null) return null;
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  /// Get the watch URL for a YouTube video
  static String? getWatchUrl(String url) {
    final videoId = extractVideoId(url);
    if (videoId == null) return null;
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  /// Normalize a YouTube URL to a standard format
  static String? normalizeUrl(String url) {
    return getWatchUrl(url);
  }

  /// Parse duration string in ISO 8601 format (PT#H#M#S) to seconds
  /// Used for parsing YouTube API duration responses
  static int? parseDuration(String isoDuration) {
    if (isoDuration.isEmpty) return null;

    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return null;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  /// Format seconds to a human-readable duration string
  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format seconds to MM:SS or HH:MM:SS format
  static String formatDurationTimestamp(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Validate and return error message if URL is invalid
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'رابط الفيديو مطلوب';
    }
    if (!isValidYouTubeUrl(url)) {
      return 'يرجى إدخال رابط يوتيوب صالح';
    }
    return null;
  }
}

/// Extension on String for YouTube URL operations
extension YouTubeStringExtension on String {
  /// Check if this string is a valid YouTube URL
  bool get isValidYouTubeUrl => YouTubeHelper.isValidYouTubeUrl(this);

  /// Extract YouTube video ID from this string
  String? get youTubeVideoId => YouTubeHelper.extractVideoId(this);

  /// Get YouTube embed URL from this string
  String? get youTubeEmbedUrl => YouTubeHelper.getEmbedUrl(this);

  /// Get YouTube thumbnail URL from this string
  String? get youTubeThumbnailUrl => YouTubeHelper.getThumbnailUrl(this);

  /// Normalize this YouTube URL
  String? get normalizedYouTubeUrl => YouTubeHelper.normalizeUrl(this);
}
