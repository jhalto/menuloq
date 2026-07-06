import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../views/main_shell_view.dart';

class MobileBottomNavBar extends StatelessWidget {
  const MobileBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<NavBarItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const Duration _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.darkCard : AppColors.surface;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
    final shadowColor = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final selectedTextStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.white,
      fontWeight: FontWeight.w900,
    );

    return SafeArea(
      top: false,
      child: RepaintBoundary(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = index == selectedIndex;

              return Flexible(
                fit: FlexFit.tight,
                flex: isSelected ? 36 : 18,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _MobileNavItem(
                    item: items[index],
                    isSelected: isSelected,
                    inactiveColor: inactiveColor,
                    selectedTextStyle: selectedTextStyle,
                    duration: _duration,
                    onTap: () => onTap(index),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  const _MobileNavItem({
    required this.item,
    required this.isSelected,
    required this.inactiveColor,
    required this.selectedTextStyle,
    required this.duration,
    required this.onTap,
  });

  final NavBarItemData item;
  final bool isSelected;
  final Color inactiveColor;
  final TextStyle? selectedTextStyle;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOut,
          height: 58,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 12 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected ? _selectedGradient : null,
            boxShadow: isSelected ? _selectedShadow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? AppColors.white : inactiveColor,
                size: 24,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      style: selectedTextStyle,
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

  static const LinearGradient _selectedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accent,
      Color(0xFF42A500),
    ],
  );

  static final List<BoxShadow> _selectedShadow = [
    BoxShadow(
      color: AppColors.accent.withAlpha(70),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}