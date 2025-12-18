import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_bottom_navigation.dart';
import '../../core/widgets/responsive_layout.dart';
import 'route_names.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      label: 'الرئيسية',
      icon: Iconsax.home,
      selectedIcon: Iconsax.home_15,
      route: RouteNames.posts,
    ),
    _NavigationItem(
      label: 'الوظائف',
      icon: Iconsax.briefcase,
      selectedIcon: Iconsax.briefcase5,
      route: RouteNames.jobs,
    ),
    _NavigationItem(
      label: 'الدورات',
      icon: Iconsax.book_1,
      selectedIcon: Iconsax.book,
      route: RouteNames.courses,
    ),
    _NavigationItem(
      label: 'المحادثات',
      icon: Iconsax.message,
      selectedIcon: Iconsax.message_2,
      route: RouteNames.chat,
    ),
    _NavigationItem(
      label: 'حسابي',
      icon: Iconsax.user,
      selectedIcon: Iconsax.user_tick,
      route: RouteNames.profile,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).matchedLocation;

    for (int i = 0; i < _navigationItems.length; i++) {
      if (location.startsWith(_navigationItems[i].route)) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        return;
      }
    }
  }

  void _onNavigationTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      context.go(_navigationItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileShell(
        currentIndex: _currentIndex,
        onNavigationTap: _onNavigationTap,
        items: _navigationItems,
        child: widget.child,
      ),
      desktop: _DesktopShell(
        currentIndex: _currentIndex,
        onNavigationTap: _onNavigationTap,
        items: _navigationItems,
        child: widget.child,
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final String? badge;
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.currentIndex,
    required this.onNavigationTap,
    required this.items,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigationTap;
  final List<_NavigationItem> items;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: GlassBottomNavigation(
        currentIndex: currentIndex,
        onTap: onNavigationTap,
        items: items
            .map(
              (item) => GlassBottomNavigationItem(
                icon: item.icon,
                selectedIcon: item.selectedIcon,
                label: item.label,
                badge: item.badge,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DesktopShell extends StatefulWidget {
  const _DesktopShell({
    required this.currentIndex,
    required this.onNavigationTap,
    required this.items,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigationTap;
  final List<_NavigationItem> items;
  final Widget child;

  @override
  State<_DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<_DesktopShell> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final isLargeDesktop = ResponsiveLayout.isLargeDesktop(context);

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: AppConstants.animationDuration,
            width: _isExpanded ? 280 : 80,
            child: _DesktopSidebar(
              currentIndex: widget.currentIndex,
              onNavigationTap: widget.onNavigationTap,
              items: widget.items,
              isExpanded: _isExpanded,
              onToggleExpanded: () {
                setState(() => _isExpanded = !_isExpanded);
              },
            ),
          ),
          Container(
            width: 1,
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          Expanded(
            child: Container(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              child: Row(
                children: [
                  Expanded(
                    flex: isLargeDesktop ? 3 : 4,
                    child: widget.child,
                  ),
                  if (isLargeDesktop) ...[
                    Container(
                      width: 1,
                      color:
                          isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                    Expanded(
                      flex: 1,
                      child: _DesktopSidePanel(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.onNavigationTap,
    required this.items,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigationTap;
  final List<_NavigationItem> items;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: AppConstants.spacingLarge),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSmall,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = index == currentIndex;

                  return _DesktopNavItem(
                    icon: isSelected ? item.selectedIcon : item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    isExpanded: isExpanded,
                    badge: item.badge,
                    onTap: () => onNavigationTap(index),
                  );
                },
              ),
            ),
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TAMAD HUB',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'منصة مهنية متكاملة',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        children: [
          _DesktopNavItem(
            icon: Iconsax.setting_2,
            label: 'الإعدادات',
            isSelected: false,
            isExpanded: isExpanded,
            onTap: () => context.go('${RouteNames.profile}/settings'),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          _DesktopNavItem(
            icon: isExpanded ? Iconsax.sidebar_right : Iconsax.sidebar_left,
            label: isExpanded ? 'طي القائمة' : 'توسيع',
            isSelected: false,
            isExpanded: isExpanded,
            onTap: onToggleExpanded,
          ),
        ],
      ),
    );
  }
}

class _DesktopNavItem extends StatefulWidget {
  const _DesktopNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final String? badge;
  final VoidCallback onTap;

  @override
  State<_DesktopNavItem> createState() => _DesktopNavItemState();
}

class _DesktopNavItemState extends State<_DesktopNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = widget.isSelected
        ? (isDark
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.1))
        : (_isHovered
            ? (isDark
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.05))
            : Colors.transparent);

    final Color foregroundColor = widget.isSelected
        ? (isDark ? AppColors.primaryLight : AppColors.primary)
        : (_isHovered
            ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
            : (isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppConstants.animationDurationFast,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: widget.isExpanded
                ? AppConstants.spacingMedium
                : AppConstants.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: widget.isSelected
                ? Border.all(
                    color: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: widget.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.icon,
                    color: foregroundColor,
                    size: AppConstants.iconSizeMedium,
                  ),
                  if (widget.badge != null && !widget.isExpanded)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.badge!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foregroundColor,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.badge!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSidePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إجراءات سريعة',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              _QuickActionTile(
                icon: Iconsax.add_circle,
                label: 'نشر وظيفة',
                onTap: () => context.push(RouteNames.postJob),
              ),
              _QuickActionTile(
                icon: Iconsax.edit,
                label: 'إنشاء منشور',
                onTap: () => context.push(RouteNames.createPost),
              ),
              _QuickActionTile(
                icon: Iconsax.building,
                label: 'شركاتي',
                onTap: () => context.push(RouteNames.companies),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              Text(
                'الإشعارات',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Expanded(
                child: Center(
                  child: Text(
                    'لا توجد إشعارات جديدة',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppConstants.animationDurationFast,
          margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Text(
                widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
