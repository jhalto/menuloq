import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../views/main_shell_view.dart';

class TabletSideNavBar extends StatelessWidget {
  const TabletSideNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<NavBarItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.darkCard : AppColors.surface;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

    return Container(
      width: 112,
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          const _MenuLoqMiniLogo(),
          const SizedBox(height: 28),
          Expanded(
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TabletNavItem(
                    item: item,
                    isSelected: index == selectedIndex,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletNavItem extends StatelessWidget {
  const _TabletNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavBarItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isSelected
              ? AppColors.accent.withAlpha(isDark ? 45 : 25)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withAlpha(120)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent,
                          Color(0xFF42A500),
                        ],
                      )
                    : null,
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? AppColors.white : inactiveColor,
                size: 23,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.accent : inactiveColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuLoqMiniLogo extends StatelessWidget {
  const _MenuLoqMiniLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.accent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(70),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'ML',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}