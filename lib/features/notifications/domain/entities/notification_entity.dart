import 'package:equatable/equatable.dart';

enum NotificationType {
  job('job', 'وظيفة'),
  message('message', 'رسالة'),
  course('course', 'دورة'),
  company('company', 'شركة'),
  like('like', 'إعجاب'),
  comment('comment', 'تعليق'),
  follow('follow', 'متابعة'),
  system('system', 'نظام');

  const NotificationType(this.value, this.label);
  final String value;
  final String label;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.message,
    this.data = const {},
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String? message;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'أمس';
      if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  String? get actionId => data['action_id'] as String?;
  String? get actionType => data['action_type'] as String?;
  String? get imageUrl => data['image_url'] as String?;

  NotificationEntity copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        message,
        data,
        isRead,
        readAt,
        createdAt,
      ];
}

class NotificationSettings extends Equatable {
  const NotificationSettings({
    this.emailEnabled = true,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.jobAlerts = true,
    this.messageAlerts = true,
    this.courseAlerts = true,
    this.socialAlerts = true,
    this.systemAlerts = true,
  });

  final bool emailEnabled;
  final bool pushEnabled;
  final bool smsEnabled;
  final bool jobAlerts;
  final bool messageAlerts;
  final bool courseAlerts;
  final bool socialAlerts;
  final bool systemAlerts;

  Map<String, dynamic> toJson() => {
        'email': emailEnabled,
        'push': pushEnabled,
        'sms': smsEnabled,
        'job_alerts': jobAlerts,
        'message_alerts': messageAlerts,
        'course_alerts': courseAlerts,
        'social_alerts': socialAlerts,
        'system_alerts': systemAlerts,
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailEnabled: json['email'] as bool? ?? true,
      pushEnabled: json['push'] as bool? ?? true,
      smsEnabled: json['sms'] as bool? ?? false,
      jobAlerts: json['job_alerts'] as bool? ?? true,
      messageAlerts: json['message_alerts'] as bool? ?? true,
      courseAlerts: json['course_alerts'] as bool? ?? true,
      socialAlerts: json['social_alerts'] as bool? ?? true,
      systemAlerts: json['system_alerts'] as bool? ?? true,
    );
  }

  NotificationSettings copyWith({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? jobAlerts,
    bool? messageAlerts,
    bool? courseAlerts,
    bool? socialAlerts,
    bool? systemAlerts,
  }) {
    return NotificationSettings(
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      jobAlerts: jobAlerts ?? this.jobAlerts,
      messageAlerts: messageAlerts ?? this.messageAlerts,
      courseAlerts: courseAlerts ?? this.courseAlerts,
      socialAlerts: socialAlerts ?? this.socialAlerts,
      systemAlerts: systemAlerts ?? this.systemAlerts,
    );
  }

  @override
  List<Object?> get props => [
        emailEnabled,
        pushEnabled,
        smsEnabled,
        jobAlerts,
        messageAlerts,
        courseAlerts,
        socialAlerts,
        systemAlerts,
      ];
}
