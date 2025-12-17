import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              role: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.jobs);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: ResponsiveLayout(
          mobile: _MobileRegisterLayout(
            formKey: _formKey,
            fullNameController: _fullNameController,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            selectedRole: _selectedRole,
            onRoleChanged: (role) => setState(() => _selectedRole = role),
            onRegister: _onRegister,
          ),
          desktop: _DesktopRegisterLayout(
            formKey: _formKey,
            fullNameController: _fullNameController,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            selectedRole: _selectedRole,
            onRoleChanged: (role) => setState(() => _selectedRole = role),
            onRegister: _onRegister,
          ),
        ),
      ),
    );
  }
}

class _MobileRegisterLayout extends StatelessWidget {
  const _MobileRegisterLayout({
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundLight,
            AppColors.primaryExtraLight,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spacingLarge),
              _buildLogo(),
              const SizedBox(height: AppConstants.spacingLarge),
              Text(
                'Create Account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'Join TAMAD HUB today',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              _RegisterForm(
                formKey: formKey,
                fullNameController: fullNameController,
                emailController: emailController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                selectedRole: selectedRole,
                onRoleChanged: onRoleChanged,
                onRegister: onRegister,
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              _buildLoginLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          boxShadow: AppColors.elevatedShadowLight,
        ),
        child: const Center(
          child: Text(
            'T',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: theme.textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () => context.go(RouteNames.login),
          child: Text(
            'Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopRegisterLayout extends StatelessWidget {
  const _DesktopRegisterLayout({
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingHuge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusExtraLarge,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'T',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      'TAMAD HUB',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      'Start Your Professional Journey\nWith Us Today',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: AppColors.backgroundLight,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingHuge),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        'Join TAMAD HUB today',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLarge),
                      _RegisterForm(
                        formKey: formKey,
                        fullNameController: fullNameController,
                        emailController: emailController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        selectedRole: selectedRole,
                        onRoleChanged: onRoleChanged,
                        onRegister: onRegister,
                      ),
                      const SizedBox(height: AppConstants.spacingLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: theme.textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.go(RouteNames.login),
                            child: Text(
                              'Sign In',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return GlassCard(
          intensity: GlassIntensity.medium,
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassTextField(
                  controller: fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Iconsax.user),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Iconsax.sms),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Text(
                  'Account Type',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(
                  children: [
                    Expanded(
                      child: _RoleChip(
                        label: 'User',
                        icon: Iconsax.user,
                        isSelected: selectedRole == UserRole.user,
                        onTap: isLoading
                            ? null
                            : () => onRoleChanged(UserRole.user),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Expanded(
                      child: _RoleChip(
                        label: 'Instructor',
                        icon: Iconsax.teacher,
                        isSelected: selectedRole == UserRole.instructor,
                        onTap: isLoading
                            ? null
                            : () => onRoleChanged(UserRole.instructor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Iconsax.lock),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassTextField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Iconsax.lock_1),
                  enabled: !isLoading,
                  onSubmitted: (_) => onRegister(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onRegister,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationDurationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.primaryExtraLight,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
