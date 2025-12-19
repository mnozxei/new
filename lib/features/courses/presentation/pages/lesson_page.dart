import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/login_required_dialog.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final TextEditingController _notesController = TextEditingController();
  bool _isBookmarked = false;
  bool _isCompleted = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  void _handleBookmark() {
    if (_isAuthenticated) {
      setState(() => _isBookmarked = !_isBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'تم حفظ الدرس' : 'تم إزالة الحفظ'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'save');
    }
  }

  void _handleSaveNotes() {
    if (!_isAuthenticated) {
      LoginRequiredDialog.showForAction(context, 'save');
      return;
    }

    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الملاحظات فارغة')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الملاحظات')),
    );
  }

  void _handleDownloadResource(String title) {
    if (_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('جاري تحميل: $title')),
      );
    } else {
      LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول لتحميل الموارد');
    }
  }

  void _handlePreviousLesson() {
    // Extract lesson number and navigate to previous
    final lessonNum = int.tryParse(widget.lessonId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    if (lessonNum > 0) {
      context.pushReplacement('/courses/${widget.courseId}/lesson/lesson-${lessonNum - 1}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذا هو الدرس الأول')),
      );
    }
  }

  void _handleCompleteAndNext() {
    if (!_isAuthenticated) {
      LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول لإكمال الدروس');
      return;
    }

    setState(() => _isCompleted = true);

    // Extract lesson number and navigate to next
    final lessonNum = int.tryParse(widget.lessonId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إكمال الدرس! ✓')),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.pushReplacement('/courses/${widget.courseId}/lesson/lesson-${lessonNum + 1}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'الدرس الأول',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Iconsax.bookmark_25 : Iconsax.bookmark),
            onPressed: _handleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              color: AppColors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('قريباً: مشغل الفيديو')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.play,
                          size: 32,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      'اضغط للتشغيل',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مقدمة في Flutter',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Row(
                    children: [
                      _LessonTag(icon: Iconsax.clock, label: '10 دقائق'),
                      const SizedBox(width: AppConstants.spacingSmall),
                      _LessonTag(icon: Iconsax.video_play, label: 'فيديو'),
                      if (_isCompleted) ...[
                        const SizedBox(width: AppConstants.spacingSmall),
                        _LessonTag(icon: Iconsax.tick_circle, label: 'مكتمل', isSuccess: true),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'وصف الدرس',
                    intensity: GlassIntensity.light,
                    child: Text(
                      'في هذا الدرس، ستتعلم أساسيات Flutter، بما في ذلك بنيته ونظام الويدجت وكيفية إعداد بيئة التطوير الخاصة بك. بنهاية هذا الدرس، سيكون لديك فهم قوي لما هو Flutter وكيف يعمل.',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'الموارد',
                    intensity: GlassIntensity.light,
                    child: Column(
                      children: [
                        _ResourceItem(
                          icon: Iconsax.document_download,
                          title: 'شرائح الدرس',
                          subtitle: 'PDF - 2.4 MB',
                          onDownload: () => _handleDownloadResource('شرائح الدرس'),
                        ),
                        const Divider(),
                        _ResourceItem(
                          icon: Iconsax.code,
                          title: 'الكود المصدري',
                          subtitle: 'ZIP - 1.2 MB',
                          onDownload: () => _handleDownloadResource('الكود المصدري'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'ملاحظاتك',
                    intensity: GlassIntensity.light,
                    child: Column(
                      children: [
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'اكتب ملاحظاتك هنا...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _handleSaveNotes,
                            icon: const Icon(Iconsax.save_2, size: 18),
                            label: const Text('حفظ الملاحظات'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _NavigationBottomSheet(
        onPrevious: _handlePreviousLesson,
        onCompleteAndNext: _handleCompleteAndNext,
        isCompleted: _isCompleted,
      ),
    );
  }
}

class _LessonTag extends StatelessWidget {
  const _LessonTag({
    required this.icon,
    required this.label,
    this.isSuccess = false,
  });

  final IconData icon;
  final String label;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSuccess ? AppColors.success : AppColors.primary;
    final bgColor = isSuccess ? AppColors.success.withValues(alpha: 0.1) : AppColors.primaryExtraLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  const _ResourceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onDownload,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryExtraLight,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Iconsax.import_1),
        onPressed: onDownload,
      ),
    );
  }
}

class _NavigationBottomSheet extends StatelessWidget {
  const _NavigationBottomSheet({
    required this.onPrevious,
    required this.onCompleteAndNext,
    required this.isCompleted,
  });

  final VoidCallback onPrevious;
  final VoidCallback onCompleteAndNext;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Iconsax.arrow_right_1),
                label: const Text('السابق'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCompleteAndNext,
                icon: Icon(isCompleted ? Iconsax.arrow_left_2 : Iconsax.tick_circle),
                label: Text(isCompleted ? 'التالي' : 'إكمال والتالي'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
