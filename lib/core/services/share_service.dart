import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Cross-platform share service that handles differences between web and native
class ShareService {
  ShareService._();

  static final ShareService _instance = ShareService._();
  static ShareService get instance => _instance;

  /// Share content - handles web vs native platforms
  Future<void> share({
    required BuildContext context,
    required String title,
    required String url,
    String? text,
  }) async {
    final shareText = text != null ? '$title\n\n$text\n\n$url' : '$title\n\n$url';

    if (kIsWeb) {
      // On web, try Web Share API first, fallback to copy to clipboard
      await _shareOnWeb(context, shareText, title, url);
    } else {
      // On native platforms, use share_plus
      await Share.share(shareText, subject: title);
    }
  }

  /// Share with files (native only - shows dialog on web)
  Future<void> shareWithFiles({
    required BuildContext context,
    required List<XFile> files,
    String? text,
    String? subject,
  }) async {
    if (kIsWeb) {
      // Web doesn't support file sharing
      _showWebShareDialog(
        context,
        text ?? 'محتوى مشترك',
        subject ?? '',
      );
    } else {
      await Share.shareXFiles(files, text: text, subject: subject);
    }
  }

  Future<void> _shareOnWeb(
    BuildContext context,
    String text,
    String title,
    String url,
  ) async {
    // Try using the Web Share API via share_plus first
    try {
      final result = await Share.share(text, subject: title);
      if (result.status == ShareResultStatus.unavailable) {
        // Fallback to copy to clipboard dialog
        if (context.mounted) {
          _showWebShareDialog(context, text, url);
        }
      }
    } catch (_) {
      // Fallback to copy to clipboard dialog
      if (context.mounted) {
        _showWebShareDialog(context, text, url);
      }
    }
  }

  void _showWebShareDialog(BuildContext context, String text, String url) {
    showDialog(
      context: context,
      builder: (context) => _WebShareDialog(text: text, url: url),
    );
  }

  /// Copy text to clipboard with feedback
  Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم النسخ إلى الحافظة'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Share post
  Future<void> sharePost({
    required BuildContext context,
    required String postId,
    String? title,
    String? excerpt,
  }) async {
    final url = '${AppConstants.appWebUrl}/posts/$postId';
    await share(
      context: context,
      title: title ?? 'منشور على ${AppConstants.appName}',
      url: url,
      text: excerpt,
    );
  }

  /// Share job
  Future<void> shareJob({
    required BuildContext context,
    required String jobId,
    required String jobTitle,
    String? company,
  }) async {
    final url = '${AppConstants.appWebUrl}/jobs/$jobId';
    final title = company != null ? '$jobTitle - $company' : jobTitle;
    await share(
      context: context,
      title: title,
      url: url,
      text: 'فرصة عمل على ${AppConstants.appName}',
    );
  }

  /// Share course
  Future<void> shareCourse({
    required BuildContext context,
    required String courseId,
    required String courseTitle,
    String? instructor,
  }) async {
    final url = '${AppConstants.appWebUrl}/courses/$courseId';
    final title = instructor != null ? '$courseTitle - $instructor' : courseTitle;
    await share(
      context: context,
      title: title,
      url: url,
      text: 'دورة تدريبية على ${AppConstants.appName}',
    );
  }

  /// Share company
  Future<void> shareCompany({
    required BuildContext context,
    required String companyId,
    required String companyName,
  }) async {
    final url = '${AppConstants.appWebUrl}/companies/$companyId';
    await share(
      context: context,
      title: companyName,
      url: url,
      text: 'شركة على ${AppConstants.appName}',
    );
  }

  /// Share profile
  Future<void> shareProfile({
    required BuildContext context,
    required String userId,
    required String userName,
  }) async {
    final url = '${AppConstants.appWebUrl}/user/$userId';
    await share(
      context: context,
      title: userName,
      url: url,
      text: 'ملف شخصي على ${AppConstants.appName}',
    );
  }

  /// Share certificate
  Future<void> shareCertificate({
    required BuildContext context,
    required String verifyCode,
    required String courseName,
    required String holderName,
  }) async {
    final url = '${AppConstants.appWebUrl}/verify/$verifyCode';
    await share(
      context: context,
      title: 'شهادة إتمام - $courseName',
      url: url,
      text: 'شهادة إتمام للدورة $courseName حاصل عليها $holderName',
    );
  }
}

class _WebShareDialog extends StatelessWidget {
  const _WebShareDialog({
    required this.text,
    required this.url,
  });

  final String text;
  final String url;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('مشاركة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('اختر طريقة المشاركة:'),
          const SizedBox(height: 16),
          _ShareOption(
            icon: Icons.copy,
            label: 'نسخ الرابط',
            onTap: () {
              Navigator.of(context).pop();
              ShareService.instance.copyToClipboard(context, url);
            },
          ),
          _ShareOption(
            icon: Icons.email,
            label: 'البريد الإلكتروني',
            onTap: () async {
              Navigator.of(context).pop();
              final emailUri = Uri(
                scheme: 'mailto',
                query: 'subject=${Uri.encodeComponent('مشاركة من ${AppConstants.appName}')}&body=${Uri.encodeComponent(text)}',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              }
            },
          ),
          _ShareOption(
            icon: Icons.open_in_new,
            label: 'فتح تويتر',
            onTap: () async {
              Navigator.of(context).pop();
              final twitterUrl = Uri.parse(
                'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(url)}',
              );
              if (await canLaunchUrl(twitterUrl)) {
                await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
              }
            },
          ),
          _ShareOption(
            icon: Icons.link,
            label: 'فتح فيسبوك',
            onTap: () async {
              Navigator.of(context).pop();
              final fbUrl = Uri.parse(
                'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}',
              );
              if (await canLaunchUrl(fbUrl)) {
                await launchUrl(fbUrl, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
