import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Service for sharing content across platforms
/// Abstracts share_plus for consistent behavior and testability
class ShareService {
  const ShareService();

  /// Share text content with optional subject
  /// Works on all platforms (iOS, Android, Web)
  Future<ShareResult> shareText(
    String text, {
    String? subject,
  }) async {
    try {
      final result = await Share.share(
        text,
        subject: subject,
      );
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('ShareService: Failed to share text: $e');
      }
      rethrow;
    }
  }

  /// Share content with a URL
  /// Constructs a shareable message with title and URL
  Future<ShareResult> shareUrl({
    required String url,
    required String title,
    String? description,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln(title);
    if (description != null && description.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(description);
    }
    buffer.writeln();
    buffer.write(url);

    return shareText(buffer.toString(), subject: title);
  }

  /// Share entity content (posts, jobs, courses, etc.)
  /// Builds appropriate share message based on entity type
  Future<ShareResult> shareEntity({
    required ShareEntityType entityType,
    required String entityId,
    required String title,
    String? description,
    String baseUrl = 'https://tamadhub.com',
  }) async {
    final url = '$baseUrl/${entityType.pathSegment}/$entityId';
    return shareUrl(
      url: url,
      title: title,
      description: description,
    );
  }
}

/// Types of shareable entities in the app
enum ShareEntityType {
  post('posts'),
  job('jobs'),
  course('courses'),
  company('companies'),
  profile('profile'),
  lesson('lessons');

  const ShareEntityType(this.pathSegment);
  final String pathSegment;
}
