import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/auth/verification_gate.dart';
import '../bloc/verification_bloc.dart';
import '../widgets/verification_status_card.dart';

class BecomeInstructorPage extends StatefulWidget {
  const BecomeInstructorPage({super.key});

  @override
  State<BecomeInstructorPage> createState() => _BecomeInstructorPageState();
}

class _BecomeInstructorPageState extends State<BecomeInstructorPage> {
  @override
  void initState() {
    super.initState();
    context.read<VerificationBloc>()
      ..add(const LoadVerificationStatus())
      ..add(const LoadInstructorApplication());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('كن مدرباً'),
      ),
      body: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationStatusCard(
                  status: state.verificationStatus,
                  application: state.instructorApplication,
                  rejectionReason: state.instructorApplication?.rejectionReason,
                  onApplyPressed: () {
                    context.push(RouteNames.instructorApplication);
                  },
                  onViewDetailsPressed: () {
                    context.push(RouteNames.verificationDocuments);
                  },
                  onReapplyPressed: () {
                    context.push(RouteNames.instructorApplication);
                  },
                ),
                const SizedBox(height: 32),
                _buildBenefitsSection(context),
                const SizedBox(height: 32),
                _buildRequirementsSection(context, state),
                const SizedBox(height: 32),
                _buildFaqSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مميزات التدريس على المنصة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildBenefitTile(
          context,
          icon: Icons.monetization_on,
          title: 'دخل مستمر',
          description: 'احصل على نسبة من كل اشتراك في دوراتك',
        ),
        _buildBenefitTile(
          context,
          icon: Icons.people,
          title: 'وصول واسع',
          description: 'شارك خبراتك مع آلاف المتعلمين',
        ),
        _buildBenefitTile(
          context,
          icon: Icons.trending_up,
          title: 'نمو مهني',
          description: 'ابنِ سمعتك كخبير في مجالك',
        ),
        _buildBenefitTile(
          context,
          icon: Icons.schedule,
          title: 'مرونة كاملة',
          description: 'أنشئ المحتوى في وقتك الخاص',
        ),
      ],
    );
  }

  Widget _buildBenefitTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(BuildContext context, VerificationState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المتطلبات',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRequirementItem(
                  context,
                  icon: Icons.badge,
                  title: 'هوية رسمية',
                  description: 'بطاقة هوية أو جواز سفر ساري',
                  isRequired: true,
                ),
                const Divider(),
                _buildRequirementItem(
                  context,
                  icon: Icons.school,
                  title: 'شهادة أكاديمية',
                  description: 'شهادة بكالوريوس أو أعلى',
                  isRequired: true,
                ),
                const Divider(),
                _buildRequirementItem(
                  context,
                  icon: Icons.work,
                  title: 'خبرة عملية',
                  description: 'سنة واحدة على الأقل في مجالك',
                  isRequired: true,
                ),
                const Divider(),
                _buildRequirementItem(
                  context,
                  icon: Icons.card_membership,
                  title: 'رخصة مهنية',
                  description: 'شهادات مهنية إن وجدت (اختياري)',
                  isRequired: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isRequired,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'مطلوب',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أسئلة شائعة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFaqItem(
          context,
          question: 'كم تستغرق عملية المراجعة؟',
          answer: 'عادة ما تستغرق المراجعة من 3 إلى 5 أيام عمل.',
        ),
        _buildFaqItem(
          context,
          question: 'هل يمكنني تعديل طلبي بعد تقديمه؟',
          answer: 'نعم، يمكنك تحديث المستندات والمعلومات حتى يتم البت في الطلب.',
        ),
        _buildFaqItem(
          context,
          question: 'ما هي نسبة الأرباح؟',
          answer: 'تحصل على 70% من إيرادات دوراتك.',
        ),
        _buildFaqItem(
          context,
          question: 'هل يمكنني التدريس بلغات متعددة؟',
          answer: 'نعم، نرحب بالمحتوى بالعربية والإنجليزية.',
        ),
      ],
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(
        question,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
