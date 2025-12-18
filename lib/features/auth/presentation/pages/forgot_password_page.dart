import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.common_error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.primaryExtraLight,
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _emailSent ? _buildSuccessView(theme, l10n) : _buildFormView(theme, l10n),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppColors.elevatedShadowLight,
          ),
          child: const Icon(
            Iconsax.tick_circle,
            size: 48,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        Text(
          l10n.forgotPassword_checkEmail,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        Text(
          l10n.forgotPassword_emailSent,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingExtraLarge),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(RouteNames.login),
            child: Text(l10n.forgotPassword_backToLogin),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView(ThemeData theme, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusExtraLarge),
              boxShadow: AppColors.elevatedShadowLight,
            ),
            child: const Center(
              child: Icon(
                Iconsax.lock,
                size: 36,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Text(
            l10n.forgotPassword_title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            l10n.forgotPassword_subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingExtraLarge),
          GlassCard(
            intensity: GlassIntensity.medium,
            child: Column(
              children: [
                GlassTextField(
                  controller: _emailController,
                  hintText: l10n.auth_emailHint,
                  prefixIcon: const Icon(Iconsax.sms),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.auth_emailRequired;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return l10n.auth_emailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(l10n.forgotPassword_sendLink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          TextButton(
            onPressed: () => context.go(RouteNames.login),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.arrow_right_1, size: 18),
                const SizedBox(width: AppConstants.spacingSmall),
                Text(l10n.forgotPassword_backToLogin),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
