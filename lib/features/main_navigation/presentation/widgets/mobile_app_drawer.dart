import 'package:flutter/material.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/core/di/dependency_factory.dart';
import 'package:menuloq/core/global/brand_word_mark.dart';

import '../views/main_shell_view.dart';

class MobileAppDrawer extends StatelessWidget {
  const MobileAppDrawer({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<NavBarItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.darkAccentLight : AppColors.accentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant_menu_rounded,
                      color: isDark ? AppColors.darkAccent : AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: BrandWordmark(fontSize: 24),
                  ),
                  IconButton(
                    tooltip: 'Close menu',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              height: 1,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                    child: Text(
                      'Workspace',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ...List.generate(items.length, (index) {
                    final item = items[index];
                    final selected = index == selectedIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        selected: selected,
                        leading: Icon(
                          selected ? item.activeIcon : item.icon,
                        ),
                        title: Text(
                          item.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: selected
                            ? const Icon(Icons.check_rounded, size: 20)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        selectedColor:
                            isDark ? AppColors.darkAccent : AppColors.accent,
                        selectedTileColor: isDark
                            ? AppColors.darkAccentLight
                            : AppColors.accentLight,
                        onTap: () {
                          Navigator.pop(context);
                          onDestinationSelected(index);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            Divider(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await DependencyFactory.instance.logout();
    navigator.pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }
}
