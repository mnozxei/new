import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// A reusable empty state widget for lists and sections
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  // Factory constructors for common empty states
  factory EmptyState.jobs({VoidCallback? onBrowse}) => EmptyState(
        icon: Iconsax.briefcase,
        title: 'لا توجد وظائف',
        message: 'لم يتم العثور على وظائف مطابقة لبحثك',
        actionLabel: onBrowse != null ? 'تصفح الوظائف' : null,
        onAction: onBrowse,
      );

  factory EmptyState.courses({VoidCallback? onBrowse}) => EmptyState(
        icon: Iconsax.book,
        title: 'لا توجد دورات',
        message: 'لم يتم العثور على دورات مطابقة',
        actionLabel: onBrowse != null ? 'تصفح الدورات' : null,
        onAction: onBrowse,
      );

  factory EmptyState.posts({VoidCallback? onCreate}) => EmptyState(
        icon: Iconsax.document,
        title: 'لا توجد منشورات',
        message: 'كن أول من يشارك شيئاً مع المجتمع',
        actionLabel: onCreate != null ? 'إنشاء منشور' : null,
        onAction: onCreate,
      );

  factory EmptyState.notifications() => const EmptyState(
        icon: Iconsax.notification,
        title: 'لا توجد إشعارات',
        message: 'ستظهر هنا الإشعارات الجديدة',
      );

  factory EmptyState.messages({VoidCallback? onNewChat}) => EmptyState(
        icon: Iconsax.message,
        title: 'لا توجد محادثات',
        message: 'ابدأ محادثة جديدة',
        actionLabel: onNewChat != null ? 'محادثة جديدة' : null,
        onAction: onNewChat,
      );

  factory EmptyState.search() => const EmptyState(
        icon: Iconsax.search_normal,
        title: 'لا توجد نتائج',
        message: 'جرب البحث بكلمات مختلفة',
      );

  factory EmptyState.saved() => const EmptyState(
        icon: Iconsax.bookmark,
        title: 'لا توجد عناصر محفوظة',
        message: 'العناصر التي تحفظها ستظهر هنا',
      );

  factory EmptyState.applications() => const EmptyState(
        icon: Iconsax.document_text,
        title: 'لا توجد طلبات',
        message: 'لم تقدم على أي وظائف بعد',
      );

  factory EmptyState.enrollments({VoidCallback? onBrowse}) => EmptyState(
        icon: Iconsax.teacher,
        title: 'لم تسجل في أي دورة',
        message: 'ابدأ رحلة التعلم الآن',
        actionLabel: onBrowse != null ? 'تصفح الدورات' : null,
        onAction: onBrowse,
      );

  factory EmptyState.companies({VoidCallback? onCreate}) => EmptyState(
        icon: Iconsax.building,
        title: 'لا توجد شركات',
        message: 'أنشئ صفحة لشركتك',
        actionLabel: onCreate != null ? 'إنشاء شركة' : null,
        onAction: onCreate,
      );

  factory EmptyState.team() => const EmptyState(
        icon: Iconsax.people,
        title: 'لا يوجد أعضاء',
        message: 'قم بدعوة أعضاء للانضمام لفريقك',
      );

  factory EmptyState.certificates() => const EmptyState(
        icon: Iconsax.medal,
        title: 'لا توجد شهادات',
        message: 'أكمل دورة للحصول على شهادة',
      );

  factory EmptyState.quizAttempts() => const EmptyState(
        icon: Iconsax.document_1,
        title: 'لا توجد محاولات',
        message: 'لم تحاول حل هذا الاختبار بعد',
      );

  factory EmptyState.comments() => const EmptyState(
        icon: Iconsax.message,
        title: 'لا توجد تعليقات',
        message: 'كن أول من يعلق',
        compact: true,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(
                message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppConstants.spacingSmall),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppConstants.spacingLarge),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A sliver version of EmptyState for use in CustomScrollView
class SliverEmptyState extends StatelessWidget {
  const SliverEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyState(
        icon: icon,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}
