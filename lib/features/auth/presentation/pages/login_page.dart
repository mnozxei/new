import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
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
          mobile: _MobileLoginLayout(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            onLogin: _onLogin,
          ),
          desktop: _DesktopLoginLayout(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            onLogin: _onLogin,
          ),
        ),
      ),
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

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
              const SizedBox(height: AppConstants.spacingHuge),
              _buildLogo(),
              const SizedBox(height: AppConstants.spacingHuge),
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'Sign in to continue to TAMAD HUB',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingExtraLarge),
              _LoginForm(
                formKey: formKey,
                emailController: emailController,
                passwordController: passwordController,
                onLogin: onLogin,
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              _buildRegisterLink(context),
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

  Widget _buildRegisterLink(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: theme.textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () => context.go(RouteNames.register),
          child: Text(
            'Sign Up',
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

class _DesktopLoginLayout extends StatelessWidget {
  const _DesktopLoginLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

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
                      'Your Professional Platform for\nJobs, Courses, and Networking',
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
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome Back',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        'Sign in to continue to TAMAD HUB',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingExtraLarge),
                      _LoginForm(
                        formKey: formKey,
                        emailController: emailController,
                        passwordController: passwordController,
                        onLogin: onLogin,
                      ),
                      const SizedBox(height: AppConstants.spacingLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.go(RouteNames.register),
                            child: Text(
                              'Sign Up',
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
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
                GlassTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Iconsax.lock),
                  enabled: !isLoading,
                  onSubmitted: (_) => onLogin(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: isLoading ? null : () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onLogin,
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
                        : const Text('Sign In'),
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
