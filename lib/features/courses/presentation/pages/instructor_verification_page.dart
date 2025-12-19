import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth.dart';
import '../../../../config/routes/route_names.dart';

/// Page for instructor verification status and document submission
class InstructorVerificationPage extends StatefulWidget {
  const InstructorVerificationPage({super.key});

  @override
  State<InstructorVerificationPage> createState() => _InstructorVerificationPageState();
}

class _InstructorVerificationPageState extends State<InstructorVerificationPage> {
  VerificationStatus _status = VerificationStatus.notSubmitted;
  bool _isLoading = true;
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    setState(() => _isLoading = true);
    // TODO: Load actual verification status from repository
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
      // Default to not submitted for demo
      _status = VerificationStatus.notSubmitted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من المدرب'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_status) {
      case VerificationStatus.notSubmitted:
        return _buildNotSubmittedView();
      case VerificationStatus.pending:
        return _buildPendingView();
      case VerificationStatus.approved:
        return _buildApprovedView();
      case VerificationStatus.rejected:
        return _buildRejectedView();
      case VerificationStatus.suspended:
        return _buildSuspendedView();
    }
  }

  Widget _buildNotSubmittedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon and title
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'كن مدرباً معتمداً',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'انضم إلى مجتمع المدربين المحترفين وشارك معرفتك مع آلاف المتعلمين',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Requirements section
          _buildSectionTitle('المتطلبات'),
          const SizedBox(height: 16),
          _buildRequirementItem(
            Icons.badge_outlined,
            'وثيقة هوية سارية',
            'جواز سفر أو بطاقة هوية وطنية',
          ),
          _buildRequirementItem(
            Icons.workspace_premium_outlined,
            'شهادات أو مؤهلات',
            'إثبات الخبرة في مجال التدريس',
          ),
          _buildRequirementItem(
            Icons.link,
            'رابط معرض الأعمال (اختياري)',
            'موقع شخصي أو ملف LinkedIn',
          ),
          const SizedBox(height: 32),

          // Benefits section
          _buildSectionTitle('المميزات'),
          const SizedBox(height: 16),
          _buildBenefitItem(Icons.attach_money, 'احصل على 70% من إيرادات الدورات'),
          _buildBenefitItem(Icons.people, 'وصول إلى آلاف المتعلمين'),
          _buildBenefitItem(Icons.analytics, 'تحليلات متقدمة لأداء الدورات'),
          _buildBenefitItem(Icons.support_agent, 'دعم فني متخصص'),
          const SizedBox(height: 32),

          // Submit button
          ElevatedButton.icon(
            onPressed: _navigateToApplication,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.send),
            label: const Text('تقديم طلب التحقق'),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 64,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'طلبك قيد المراجعة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'سيتم مراجعة طلبك خلال 2-3 أيام عمل.\nسنرسل إشعاراً عند اتخاذ القرار.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تم التحقق بنجاح!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'يمكنك الآن إنشاء الدورات والوصول إلى لوحة تحكم المدرب',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.instructorDashboard),
              icon: const Icon(Icons.dashboard),
              label: const Text('الذهاب إلى لوحة التحكم'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تم رفض الطلب',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_rejectionReason != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سبب الرفض:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_rejectionReason!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'يمكنك تصحيح المشاكل وإعادة التقديم',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToApplication,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة التقديم'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspendedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'الحساب موقوف',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'تم تعليق صلاحيات المدرب الخاصة بك.\nيرجى التواصل مع الدعم للمزيد من المعلومات.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Open support contact
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('تواصل مع الدعم'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildRequirementItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  void _navigateToApplication() {
    context.push(RouteNames.instructorApplication);
  }
}
