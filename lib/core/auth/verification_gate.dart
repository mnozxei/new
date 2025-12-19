import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/route_names.dart';
import 'user_role.dart';

/// Verification status for instructors and companies
enum VerificationStatus {
  notSubmitted,
  pending,
  approved,
  rejected,
  suspended;

  static VerificationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'not_submitted':
      case 'notsubmitted':
        return VerificationStatus.notSubmitted;
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'suspended':
        return VerificationStatus.suspended;
      default:
        return VerificationStatus.notSubmitted;
    }
  }

  String get value {
    switch (this) {
      case VerificationStatus.notSubmitted:
        return 'not_submitted';
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
      case VerificationStatus.suspended:
        return 'suspended';
    }
  }

  String get displayName {
    switch (this) {
      case VerificationStatus.notSubmitted:
        return 'لم يتم التقديم';
      case VerificationStatus.pending:
        return 'قيد المراجعة';
      case VerificationStatus.approved:
        return 'معتمد';
      case VerificationStatus.rejected:
        return 'مرفوض';
      case VerificationStatus.suspended:
        return 'موقوف';
    }
  }

  String get displayNameEn {
    switch (this) {
      case VerificationStatus.notSubmitted:
        return 'Not Submitted';
      case VerificationStatus.pending:
        return 'Pending Review';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.suspended:
        return 'Suspended';
    }
  }

  bool get isApproved => this == VerificationStatus.approved;
  bool get isPending => this == VerificationStatus.pending;
  bool get isRejected => this == VerificationStatus.rejected;
  bool get isSuspended => this == VerificationStatus.suspended;
  bool get isNotSubmitted => this == VerificationStatus.notSubmitted;

  /// Can the user resubmit verification?
  bool get canResubmit =>
      this == VerificationStatus.notSubmitted ||
      this == VerificationStatus.rejected;
}

/// Verification gate for checking and enforcing verification status
class VerificationGate {
  VerificationGate._();

  /// Check if instructor verification is required and approved
  static bool isInstructorVerified({
    required UserRole role,
    required VerificationStatus? instructorStatus,
  }) {
    // Admin always has access
    if (role.isAdmin) return true;

    // Non-instructors don't need verification for instructor features
    // (they won't have access anyway)
    if (!role.isInstructor) return false;

    // Instructors need approved verification
    return instructorStatus?.isApproved ?? false;
  }

  /// Check if company verification is required and approved
  static bool isCompanyVerified({
    required UserRole role,
    required VerificationStatus? companyStatus,
  }) {
    // Admin always has access
    if (role.isAdmin) return true;

    // Non-company roles don't need verification for company features
    if (!role.isCompanyRole) return false;

    // Company roles need approved verification for training features
    return companyStatus?.isApproved ?? false;
  }

  /// Get the appropriate redirect URL for an unverified user
  static String getVerificationRedirect({
    required UserRole role,
    required VerificationStatus? instructorStatus,
    required VerificationStatus? companyStatus,
    String? companyId,
  }) {
    if (role.isInstructor && !(instructorStatus?.isApproved ?? false)) {
      return RouteNames.instructorVerification;
    }

    if (role.isCompanyRole && !(companyStatus?.isApproved ?? false)) {
      if (companyId != null) {
        return '/companies/$companyId/verification';
      }
      return RouteNames.companies;
    }

    return RouteNames.posts;
  }

  /// Show verification required dialog
  static Future<void> showVerificationRequiredDialog(
    BuildContext context, {
    required UserRole role,
    required VerificationStatus? status,
    VoidCallback? onApply,
    VoidCallback? onDismiss,
  }) async {
    final isInstructor = role.isInstructor;
    final title = isInstructor ? 'التحقق من المدرب مطلوب' : 'التحقق من الشركة مطلوب';

    String message;
    String? actionText;
    VoidCallback? action;

    if (status == null || status.isNotSubmitted) {
      message = isInstructor
          ? 'يجب تقديم طلب التحقق كمدرب قبل إنشاء الدورات'
          : 'يجب التحقق من الشركة قبل إنشاء دورات تدريبية';
      actionText = 'تقديم طلب';
      action = onApply;
    } else if (status.isPending) {
      message = 'طلب التحقق الخاص بك قيد المراجعة. سيتم إعلامك عند الموافقة.';
    } else if (status.isRejected) {
      message = 'تم رفض طلب التحقق. يمكنك إعادة التقديم بمستندات محدثة.';
      actionText = 'إعادة التقديم';
      action = onApply;
    } else if (status.isSuspended) {
      message = 'تم تعليق حسابك. يرجى التواصل مع الدعم.';
    } else {
      message = 'يجب إكمال التحقق للوصول إلى هذه الميزة.';
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('إغلاق'),
          ),
          if (actionText != null && action != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                action();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  /// Navigate with verification check
  static void navigateWithVerificationCheck(
    BuildContext context, {
    required String targetPath,
    required UserRole role,
    required VerificationStatus? instructorStatus,
    required VerificationStatus? companyStatus,
    String? companyId,
    VoidCallback? onVerificationRequired,
  }) {
    // Check if the route requires verification
    final requiresInstructorVerification =
        role.isInstructor && _isInstructorRoute(targetPath);
    final requiresCompanyVerification =
        role.isCompanyRole && _isCompanyTrainingRoute(targetPath);

    if (requiresInstructorVerification &&
        !isInstructorVerified(role: role, instructorStatus: instructorStatus)) {
      // Show verification dialog or redirect
      if (onVerificationRequired != null) {
        onVerificationRequired();
      } else {
        context.push(RouteNames.instructorVerification);
      }
      return;
    }

    if (requiresCompanyVerification &&
        !isCompanyVerified(role: role, companyStatus: companyStatus)) {
      // Show verification dialog or redirect
      if (onVerificationRequired != null) {
        onVerificationRequired();
      } else {
        final redirect = getVerificationRedirect(
          role: role,
          instructorStatus: instructorStatus,
          companyStatus: companyStatus,
          companyId: companyId,
        );
        context.push(redirect);
      }
      return;
    }

    // Verification passed or not required, navigate normally
    context.push(targetPath);
  }

  /// Check if a path is an instructor route that requires verification
  static bool _isInstructorRoute(String path) {
    final instructorPaths = [
      '/instructor',
      '/instructor/courses',
      '/instructor/courses/new',
    ];

    for (final p in instructorPaths) {
      if (path.startsWith(p)) return true;
    }

    // Pattern matching for specific routes
    if (path.contains('/instructor/courses/') &&
        (path.contains('/edit') ||
            path.contains('/analytics') ||
            path.contains('/quiz') ||
            path.contains('/certificate'))) {
      return true;
    }

    return false;
  }

  /// Check if a path is a company training route that requires verification
  static bool _isCompanyTrainingRoute(String path) {
    return path.contains('/training');
  }
}

/// Widget that wraps content and shows verification required message if needed
class VerificationGateWidget extends StatelessWidget {
  const VerificationGateWidget({
    super.key,
    required this.role,
    required this.instructorStatus,
    required this.companyStatus,
    required this.requiresInstructorVerification,
    required this.requiresCompanyVerification,
    required this.child,
    this.onApplyForVerification,
    this.verificationRequiredBuilder,
  });

  final UserRole role;
  final VerificationStatus? instructorStatus;
  final VerificationStatus? companyStatus;
  final bool requiresInstructorVerification;
  final bool requiresCompanyVerification;
  final Widget child;
  final VoidCallback? onApplyForVerification;
  final Widget Function(BuildContext, VerificationStatus?)? verificationRequiredBuilder;

  @override
  Widget build(BuildContext context) {
    // Check instructor verification
    if (requiresInstructorVerification &&
        !VerificationGate.isInstructorVerified(
          role: role,
          instructorStatus: instructorStatus,
        )) {
      if (verificationRequiredBuilder != null) {
        return verificationRequiredBuilder!(context, instructorStatus);
      }
      return _buildVerificationRequired(
        context,
        isInstructor: true,
        status: instructorStatus,
      );
    }

    // Check company verification
    if (requiresCompanyVerification &&
        !VerificationGate.isCompanyVerified(
          role: role,
          companyStatus: companyStatus,
        )) {
      if (verificationRequiredBuilder != null) {
        return verificationRequiredBuilder!(context, companyStatus);
      }
      return _buildVerificationRequired(
        context,
        isInstructor: false,
        status: companyStatus,
      );
    }

    // Verification passed or not required
    return child;
  }

  Widget _buildVerificationRequired(
    BuildContext context, {
    required bool isInstructor,
    required VerificationStatus? status,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isInstructor ? 'التحقق من المدرب مطلوب' : 'التحقق من الشركة مطلوب',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusMessage(status, isInstructor),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (status == null ||
                status.isNotSubmitted ||
                status.isRejected) ...[
              ElevatedButton.icon(
                onPressed: onApplyForVerification,
                icon: const Icon(Icons.upload_file),
                label: Text(status?.isRejected == true ? 'إعادة التقديم' : 'تقديم طلب التحقق'),
              ),
            ] else if (status.isPending) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'جاري مراجعة طلبك...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(VerificationStatus? status, bool isInstructor) {
    if (status == null || status.isNotSubmitted) {
      return isInstructor
          ? 'يجب تقديم مستندات التحقق كمدرب للوصول إلى لوحة التحكم وإنشاء الدورات'
          : 'يجب التحقق من الشركة للوصول إلى ميزات التدريب المؤسسي';
    }

    switch (status) {
      case VerificationStatus.pending:
        return 'طلب التحقق قيد المراجعة. سيتم إعلامك عند الموافقة.';
      case VerificationStatus.rejected:
        return 'تم رفض طلب التحقق. يمكنك مراجعة الملاحظات وإعادة التقديم.';
      case VerificationStatus.suspended:
        return 'تم تعليق حسابك. يرجى التواصل مع الدعم.';
      default:
        return 'يجب إكمال التحقق للوصول إلى هذه الميزة.';
    }
  }
}
