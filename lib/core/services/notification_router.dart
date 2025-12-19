import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/route_names.dart';
import '../../features/notifications/domain/entities/notification_entity.dart';

/// Service to handle notification deep linking
class NotificationRouter {
  NotificationRouter._();

  /// Navigate to the appropriate screen based on notification type and data
  static void navigate(BuildContext context, NotificationEntity notification) {
    final data = notification.data;
    final entityId = data['entity_id'] as String?;
    final parentId = data['parent_id'] as String?;

    switch (notification.type) {
      case NotificationType.job:
        _navigateToJob(context, entityId, data);
      case NotificationType.message:
        _navigateToChat(context, entityId);
      case NotificationType.course:
        _navigateToCourse(context, entityId, data);
      case NotificationType.company:
        _navigateToCompany(context, entityId, data);
      case NotificationType.like:
      case NotificationType.comment:
        _navigateToPost(context, entityId ?? parentId);
      case NotificationType.follow:
        _navigateToProfile(context, entityId);
      case NotificationType.system:
        _handleSystemNotification(context, data);
    }
  }

  static void _navigateToJob(
    BuildContext context,
    String? jobId,
    Map<String, dynamic> data,
  ) {
    final action = data['action'] as String?;

    if (action == 'application_status') {
      // Navigate to my applications
      context.push(RouteNames.myApplications);
    } else if (jobId != null) {
      // Navigate to job details
      context.push('/jobs/$jobId');
    } else {
      context.push(RouteNames.jobs);
    }
  }

  static void _navigateToChat(BuildContext context, String? chatId) {
    if (chatId != null) {
      context.pushNamed(RouteNames.chatRoom, pathParameters: {'id': chatId});
    } else {
      context.push(RouteNames.chat);
    }
  }

  static void _navigateToCourse(
    BuildContext context,
    String? courseId,
    Map<String, dynamic> data,
  ) {
    final action = data['action'] as String?;

    if (action == 'certificate_issued') {
      final certificateId = data['certificate_id'] as String?;
      if (certificateId != null) {
        context.push('/certificates/$certificateId');
      } else if (courseId != null) {
        context.push('/courses/$courseId');
      }
    } else if (action == 'lesson_unlocked' || action == 'quiz_available') {
      context.push(RouteNames.myLearning);
    } else if (courseId != null) {
      context.push('/courses/$courseId');
    } else {
      context.push(RouteNames.courses);
    }
  }

  static void _navigateToCompany(
    BuildContext context,
    String? companyId,
    Map<String, dynamic> data,
  ) {
    final action = data['action'] as String?;

    if (action == 'team_invite' || action == 'team_change') {
      if (companyId != null) {
        context.push('/companies/$companyId/team');
      } else {
        context.push(RouteNames.companies);
      }
    } else if (action == 'verification_status') {
      if (companyId != null) {
        context.push('/companies/$companyId/verification');
      } else {
        context.push(RouteNames.companies);
      }
    } else if (companyId != null) {
      context.push('/companies/$companyId');
    } else {
      context.push(RouteNames.companies);
    }
  }

  static void _navigateToPost(BuildContext context, String? postId) {
    if (postId != null) {
      context.push('/posts/$postId');
    } else {
      context.push(RouteNames.posts);
    }
  }

  static void _navigateToProfile(BuildContext context, String? userId) {
    if (userId != null) {
      context.push('/user/$userId');
    } else {
      context.push(RouteNames.profile);
    }
  }

  static void _handleSystemNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final action = data['action'] as String?;

    switch (action) {
      case 'instructor_verification':
        context.push(RouteNames.instructorVerification);
      case 'instructor_application':
        context.push(RouteNames.instructorApplication);
      case 'admin_action':
        final target = data['target'] as String?;
        if (target != null) {
          context.push(target);
        }
      default:
        // Do nothing for generic system notifications
        break;
    }
  }
}
