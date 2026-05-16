import 'dart:ui';


import '../core/app_export.dart';
import '../routes/app_routes.dart';

// TODO: Replace with Riverpod/Bloc for production navigation state
class AppNavigation extends StatelessWidget {
  final int currentIndex;

  const AppNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    if (isTablet) {
      return _buildNavigationRail(context);
    }
    return _buildBottomNav(context);
  }

  Widget _buildBottomNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  iconName: 'home',
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => _navigate(context, 0),
                ),
                _NavItem(
                  iconName: 'search',
                  label: 'Search',
                  isActive: currentIndex == 1,
                  onTap: () => _navigate(context, 1),
                ),
                _NavItem(
                  iconName: 'favorite',
                  label: 'Liked',
                  isActive: currentIndex == 2,
                  onTap: () => _navigate(context, 2),
                ),
                _NavItem(
                  iconName: 'settings',
                  label: 'Settings',
                  isActive: currentIndex == 3,
                  onTap: () => _navigate(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RailItem(
                iconName: 'home',
                isActive: currentIndex == 0,
                onTap: () => _navigate(context, 0),
              ),
              const SizedBox(height: 16),
              _RailItem(
                iconName: 'search',
                isActive: currentIndex == 1,
                onTap: () => _navigate(context, 1),
              ),
              const SizedBox(height: 16),
              _RailItem(
                iconName: 'favorite',
                isActive: currentIndex == 2,
                onTap: () => _navigate(context, 2),
              ),
              const SizedBox(height: 16),
              _RailItem(
                iconName: 'settings',
                isActive: currentIndex == 3,
                onTap: () => _navigate(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.reelsFeedScreen,
          (r) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.reelsFeedScreen,
          (r) => false,
        );
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.reelsFeedScreen,
          (r) => false,
        );
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.settingsScreen,
          (r) => false,
        );
        break;
    }
  }
}

class _NavItem extends StatelessWidget {
  final String iconName;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconName,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: isActive
              ? Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isActive
                  ? AppTheme.primary
                  : Colors.white.withValues(alpha: 0.5),
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final String iconName;
  final bool isActive;
  final VoidCallback onTap;

  const _RailItem({
    required this.iconName,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: iconName,
            color: isActive
                ? AppTheme.primary
                : Colors.white.withValues(alpha: 0.5),
            size: 24,
          ),
        ),
      ),
    );
  }
}
