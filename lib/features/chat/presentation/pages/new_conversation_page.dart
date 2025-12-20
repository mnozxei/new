import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../search/data/datasources/search_remote_data_source.dart';
import '../../../search/domain/entities/search_entity.dart';
import '../bloc/chat_bloc.dart';

class NewConversationPage extends StatefulWidget {
  const NewConversationPage({super.key});

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserSearchResult> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  late final SearchRemoteDataSource _searchDataSource;

  @override
  void initState() {
    super.initState();
    _searchDataSource = GetIt.instance<SearchRemoteDataSource>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await _searchDataSource.searchUsers(
        query,
        limit: 20,
        offset: 0,
      );

      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'فشل البحث. يرجى المحاولة مرة أخرى.';
        });
      }
    }
  }

  void _startConversation(UserSearchResult user) {
    context.read<ChatBloc>().add(StartConversation(participantId: user.id));
    Navigator.of(context).pop();
    // Navigate to chat room after starting conversation
    context.pushNamed(RouteNames.chatRoom, pathParameters: {'id': user.id});
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.substring(0, name.length >= 2 ? 2 : name.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isBottomSheet = mediaQuery.viewInsets.bottom > 0 || mediaQuery.size.height > 600;

    return Container(
      height: isBottomSheet ? mediaQuery.size.height * 0.8 : null,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMedium,
              vertical: AppConstants.spacingSmall,
            ),
            child: Row(
              children: [
                Text(
                  'محادثة جديدة',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Search field
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: GlassTextField(
              controller: _searchController,
              hintText: 'ابحث عن مستخدم...',
              prefixIcon: const Icon(Iconsax.search_normal),
              onChanged: _onSearchChanged,
              autofocus: true,
            ),
          ),
          // Results
          Expanded(
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            TextButton(
              onPressed: () => _onSearchChanged(_searchController.text),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_normal, size: 48, color: AppColors.textTertiaryLight),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'ابحث عن مستخدم لبدء محادثة',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.user_search, size: 48, color: AppColors.textTertiaryLight),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لم يتم العثور على مستخدمين',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserResultItem(
          user: user,
          onTap: () => _startConversation(user),
          getInitials: _getInitials,
        );
      },
    );
  }
}

class _UserResultItem extends StatelessWidget {
  const _UserResultItem({
    required this.user,
    required this.onTap,
    required this.getInitials,
  });

  final UserSearchResult user;
  final VoidCallback onTap;
  final String Function(String) getInitials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLighter,
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      getInitials(user.displayName),
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Iconsax.verify5, size: 16, color: AppColors.primary),
                      ],
                    ],
                  ),
                  if (user.headline != null)
                    Text(
                      user.headline!,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                    ),
                ],
              ),
            ),
            Icon(Iconsax.message_add, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
