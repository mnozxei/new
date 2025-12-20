import 'package:flutter/services.dart';

/// Enterprise policy for post content validation.
/// Enforces no-links rule and other content policies.
class PostContentPolicy {
  PostContentPolicy._();

  /// URL patterns to detect (comprehensive list)
  static final _urlPatterns = [
    // HTTP/HTTPS URLs
    RegExp(r'https?://[^\s]+', caseSensitive: false),
    // www URLs
    RegExp(r'www\.[^\s]+', caseSensitive: false),
    // Domain patterns (common TLDs)
    RegExp(
      r'[a-zA-Z0-9][-a-zA-Z0-9]*\.(com|org|net|io|sa|ae|eg|kw|qa|bh|om|jo|lb|ly|tn|ma|dz|sd|ye|sy|iq|ps|edu|gov|co|me|tv|info|biz|app|dev|cloud|store|online|site|tech|design|blog|shop|xyz|ai|ml)[/\s\b]?',
      caseSensitive: false,
    ),
    // IP addresses
    RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
  ];

  /// Error message in Arabic
  static const errorMessage = 'الروابط غير مسموح بها في المنشورات';

  /// Check if content contains any URL
  static bool containsUrl(String content) {
    if (content.isEmpty) return false;

    for (final pattern in _urlPatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    return false;
  }

  /// Find all URLs in content (for highlighting)
  static List<String> findUrls(String content) {
    if (content.isEmpty) return [];

    final urls = <String>[];
    for (final pattern in _urlPatterns) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        urls.add(match.group(0) ?? '');
      }
    }
    return urls.toSet().toList();
  }

  /// Validate content and return error message if invalid
  static String? validate(String? content) {
    if (content == null || content.isEmpty) {
      return 'المحتوى مطلوب';
    }

    if (content.trim().isEmpty) {
      return 'المحتوى لا يمكن أن يكون فارغاً';
    }

    if (containsUrl(content)) {
      return errorMessage;
    }

    if (content.length > 5000) {
      return 'المحتوى طويل جداً (الحد الأقصى 5000 حرف)';
    }

    return null;
  }

  /// Clean content by removing URLs (optional, use with caution)
  static String removeUrls(String content) {
    var cleaned = content;
    for (final pattern in _urlPatterns) {
      cleaned = cleaned.replaceAll(pattern, '[رابط محذوف]');
    }
    return cleaned;
  }

  /// Maximum content length
  static const maxContentLength = 5000;

  /// Minimum content length
  static const minContentLength = 1;

  /// Allowed media types
  static const allowedMediaTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

  /// Maximum media size in bytes (10MB)
  static const maxMediaSize = 10 * 1024 * 1024;

  /// Maximum number of media items per post
  static const maxMediaCount = 4;

  /// Validate media type
  static bool isValidMediaType(String mimeType) {
    return allowedMediaTypes.contains(mimeType.toLowerCase());
  }

  /// Validate media size
  static bool isValidMediaSize(int sizeInBytes) {
    return sizeInBytes <= maxMediaSize;
  }
}

/// Text input formatter that blocks URLs in real-time
class NoLinksInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Check if new text contains URL
    if (PostContentPolicy.containsUrl(newValue.text)) {
      // Block the change that introduced the URL
      // Find where the URL was added and reject that part
      final urlsInOld = PostContentPolicy.findUrls(oldValue.text);
      final urlsInNew = PostContentPolicy.findUrls(newValue.text);

      // If new URL was added, reject the edit
      if (urlsInNew.length > urlsInOld.length) {
        return oldValue;
      }

      // If URL is being typed character by character, block at completion
      for (final url in urlsInNew) {
        if (!urlsInOld.contains(url)) {
          return oldValue;
        }
      }
    }

    return newValue;
  }
}

/// Validator function for form fields
String? validatePostContent(String? value) {
  return PostContentPolicy.validate(value);
}
