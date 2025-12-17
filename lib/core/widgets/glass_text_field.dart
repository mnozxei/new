import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class GlassTextField extends StatefulWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.labelText,
    this.hint,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.blurSigma,
    this.opacity,
    this.borderRadius,
    this.contentPadding,
    this.filled = true,
    this.showCounter = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textAlign = TextAlign.start,
    this.style,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? labelText;
  final String? hint;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final double? blurSigma;
  final double? opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool filled;
  final bool showCounter;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _isObscured = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveBlur = widget.blurSigma ?? 8;
    final double effectiveOpacity = widget.opacity ?? 0.1;
    final BorderRadius effectiveBorderRadius = widget.borderRadius ??
        BorderRadius.circular(AppConstants.borderRadiusMedium);

    final bool hasError = widget.errorText != null;

    Color getBorderColor() {
      if (hasError) {
        return isDark ? AppColors.errorLight : AppColors.error;
      }
      if (_isFocused) {
        return isDark ? AppColors.primaryLight : AppColors.primary;
      }
      return Colors.transparent;
    }

    Color getFillColor() {
      if (!widget.enabled) {
        return isDark
            ? AppColors.primaryDarkest.withValues(alpha: 0.3)
            : AppColors.primaryLightest.withValues(alpha: 0.5);
      }
      if (_isFocused) {
        return isDark
            ? AppColors.primary.withValues(alpha: effectiveOpacity + 0.05)
            : AppColors.primary.withValues(alpha: effectiveOpacity + 0.02);
      }
      return isDark
          ? AppColors.primaryDark.withValues(alpha: effectiveOpacity)
          : AppColors.primaryExtraLight;
    }

    Widget? buildSuffixIcon() {
      if (widget.obscureText) {
        return IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          onPressed: _toggleObscure,
        );
      }
      return widget.suffixIcon;
    }

    final effectiveLabel = widget.label ?? widget.labelText;
    final effectiveHint = widget.hint ?? widget.hintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (effectiveLabel != null)
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppConstants.spacingSmall,
              right: AppConstants.spacingExtraSmall,
            ),
            child: Text(
              effectiveLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: hasError
                    ? (isDark ? AppColors.errorLight : AppColors.error)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: effectiveBlur,
              sigmaY: effectiveBlur,
            ),
            child: AnimatedContainer(
              duration: AppConstants.animationDurationFast,
              decoration: BoxDecoration(
                borderRadius: effectiveBorderRadius,
                border: Border.all(
                  color: getBorderColor(),
                  width: _isFocused || hasError ? 2 : 1,
                ),
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: _isObscured,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                textCapitalization: widget.textCapitalization,
                inputFormatters: widget.inputFormatters,
                validator: widget.validator,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                onEditingComplete: widget.onEditingComplete,
                autocorrect: widget.autocorrect,
                enableSuggestions: widget.enableSuggestions,
                textAlign: widget.textAlign,
                style: widget.style ??
                    theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                decoration: InputDecoration(
                  hintText: effectiveHint,
                  helperText: widget.helperText,
                  errorText: null,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: buildSuffixIcon(),
                  prefix: widget.prefix,
                  suffix: widget.suffix,
                  filled: widget.filled,
                  fillColor: getFillColor(),
                  contentPadding: widget.contentPadding ??
                      const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMedium,
                        vertical: AppConstants.spacingMedium,
                      ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  counterText: widget.showCounter ? null : '',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(
              top: AppConstants.spacingSmall,
              right: AppConstants.spacingExtraSmall,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: isDark ? AppColors.errorLight : AppColors.error,
                ),
                const SizedBox(width: AppConstants.spacingExtraSmall),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.errorLight : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (widget.helperText != null && !hasError)
          Padding(
            padding: const EdgeInsets.only(
              top: AppConstants.spacingSmall,
              right: AppConstants.spacingExtraSmall,
            ),
            child: Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ),
      ],
    );
  }
}

class GlassSearchField extends StatefulWidget {
  const GlassSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
    this.blurSigma,
    this.opacity,
    this.borderRadius,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;
  final double? blurSigma;
  final double? opacity;
  final BorderRadius? borderRadius;

  @override
  State<GlassSearchField> createState() => _GlassSearchFieldState();
}

class _GlassSearchFieldState extends State<GlassSearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return GlassTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      hint: widget.hint ?? 'Search...',
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      blurSigma: widget.blurSigma,
      opacity: widget.opacity,
      borderRadius: widget.borderRadius,
      prefixIcon: Icon(
        Icons.search,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      suffixIcon: _hasText
          ? IconButton(
              icon: Icon(
                Icons.close,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              onPressed: _handleClear,
            )
          : null,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}

class GlassDropdownField<T> extends StatelessWidget {
  const GlassDropdownField({
    required this.items,
    required this.onChanged,
    super.key,
    this.value,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.blurSigma,
    this.opacity,
    this.borderRadius,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.prefixIcon,
  });

  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final double? blurSigma;
  final double? opacity;
  final BorderRadius? borderRadius;
  final Widget Function(T item)? itemBuilder;
  final Widget Function(T item)? selectedItemBuilder;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? 8;
    final double effectiveOpacity = opacity ?? 0.1;
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium);

    final bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppConstants.spacingSmall,
              right: AppConstants.spacingExtraSmall,
            ),
            child: Text(
              label!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: hasError
                    ? (isDark ? AppColors.errorLight : AppColors.error)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: effectiveBlur,
              sigmaY: effectiveBlur,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryDark.withValues(alpha: effectiveOpacity)
                    : AppColors.primaryExtraLight,
                borderRadius: effectiveBorderRadius,
                border: Border.all(
                  color: hasError
                      ? (isDark ? AppColors.errorLight : AppColors.error)
                      : Colors.transparent,
                  width: hasError ? 2 : 1,
                ),
              ),
              child: DropdownButtonFormField<T>(
                value: value,
                items: items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: itemBuilder?.call(item) ??
                            Text(
                              item.toString(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                      ),
                    )
                    .toList(),
                onChanged: enabled ? onChanged : null,
                selectedItemBuilder: selectedItemBuilder != null
                    ? (context) => items
                        .map((item) => selectedItemBuilder!.call(item))
                        .toList()
                    : null,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: prefixIcon,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMedium,
                    vertical: AppConstants.spacingMedium,
                  ),
                  filled: false,
                ),
                dropdownColor:
                    isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: effectiveBorderRadius,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(
              top: AppConstants.spacingSmall,
              right: AppConstants.spacingExtraSmall,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: isDark ? AppColors.errorLight : AppColors.error,
                ),
                const SizedBox(width: AppConstants.spacingExtraSmall),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.errorLight : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
