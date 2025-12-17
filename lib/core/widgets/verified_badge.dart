import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    this.size = VerifiedBadgeSize.medium,
    this.showTooltip = true,
    this.tooltipMessage,
  });

  final VerifiedBadgeSize size;
  final bool showTooltip;
  final String? tooltipMessage;

  double get _iconSize {
    switch (size) {
      case VerifiedBadgeSize.small:
        return 14;
      case VerifiedBadgeSize.medium:
        return 18;
      case VerifiedBadgeSize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget badge = Container(
      padding: EdgeInsets.all(size == VerifiedBadgeSize.small ? 1 : 2),
      decoration: const BoxDecoration(
        color: AppColors.verifiedBadge,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: AppColors.white,
        size: _iconSize - 4,
      ),
    );

    if (!showTooltip) {
      return badge;
    }

    return Tooltip(
      message: tooltipMessage ?? 'Verified',
      child: badge,
    );
  }
}

class VerifiedBadgeWithLabel extends StatelessWidget {
  const VerifiedBadgeWithLabel({
    super.key,
    this.label,
    this.size = VerifiedBadgeSize.medium,
    this.labelStyle,
    this.spacing = AppConstants.spacingExtraSmall,
  });

  final String? label;
  final VerifiedBadgeSize size;
  final TextStyle? labelStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VerifiedBadge(size: size, showTooltip: false),
        SizedBox(width: spacing),
        Text(
          label ?? 'Verified',
          style: labelStyle ??
              theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.verifiedBadge
                    : AppColors.verifiedBadge.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class CompanyVerifiedBadge extends StatelessWidget {
  const CompanyVerifiedBadge({
    required this.isVerified,
    super.key,
    this.size = VerifiedBadgeSize.medium,
    this.showLabel = false,
    this.labelStyle,
  });

  final bool isVerified;
  final VerifiedBadgeSize size;
  final bool showLabel;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    if (!isVerified) {
      return const SizedBox.shrink();
    }

    if (showLabel) {
      return VerifiedBadgeWithLabel(
        label: 'Company Verified',
        size: size,
        labelStyle: labelStyle,
      );
    }

    return VerifiedBadge(
      size: size,
      tooltipMessage: 'Verified Company',
    );
  }
}

class UserVerifiedIndicator extends StatelessWidget {
  const UserVerifiedIndicator({
    required this.name,
    required this.isVerified,
    super.key,
    this.nameStyle,
    this.badgeSize = VerifiedBadgeSize.small,
    this.spacing = AppConstants.spacingExtraSmall,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final String name;
  final bool isVerified;
  final TextStyle? nameStyle;
  final VerifiedBadgeSize badgeSize;
  final double spacing;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            name,
            style: nameStyle ?? theme.textTheme.titleMedium,
            maxLines: maxLines,
            overflow: overflow,
          ),
        ),
        if (isVerified) ...[
          SizedBox(width: spacing),
          VerifiedBadge(size: badgeSize),
        ],
      ],
    );
  }
}

enum VerifiedBadgeSize {
  small,
  medium,
  large,
}

class VerificationStatusChip extends StatelessWidget {
  const VerificationStatusChip({
    required this.status,
    super.key,
  });

  final VerificationStatus status;

  Color get _backgroundColor {
    switch (status) {
      case VerificationStatus.pending:
        return AppColors.warningBackground;
      case VerificationStatus.verified:
        return AppColors.successBackground;
      case VerificationStatus.rejected:
        return AppColors.errorBackground;
      case VerificationStatus.notSubmitted:
        return AppColors.primaryLightest;
    }
  }

  Color get _foregroundColor {
    switch (status) {
      case VerificationStatus.pending:
        return AppColors.warningDark;
      case VerificationStatus.verified:
        return AppColors.successDark;
      case VerificationStatus.rejected:
        return AppColors.errorDark;
      case VerificationStatus.notSubmitted:
        return AppColors.textSecondaryLight;
    }
  }

  IconData get _icon {
    switch (status) {
      case VerificationStatus.pending:
        return Icons.hourglass_empty;
      case VerificationStatus.verified:
        return Icons.verified;
      case VerificationStatus.rejected:
        return Icons.cancel_outlined;
      case VerificationStatus.notSubmitted:
        return Icons.upload_file_outlined;
    }
  }

  String get _label {
    switch (status) {
      case VerificationStatus.pending:
        return 'Pending Review';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.notSubmitted:
        return 'Not Submitted';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 16,
            color: _foregroundColor,
          ),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            _label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: _foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
  notSubmitted,
}
