import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/core/di/dependency_factory.dart';
import 'package:menuloq/features/account/presentation/bloc/my_account_bloc.dart';
import 'package:menuloq/features/account/presentation/bloc/my_account_event.dart';
import 'package:menuloq/features/account/presentation/views/my_account_view.dart';
import 'package:menuloq/features/business_setting/presentation/bloc/business_settings_bloc.dart';
import 'package:menuloq/features/business_setting/presentation/bloc/business_settings_event.dart';
import 'package:menuloq/features/business_setting/presentation/views/business_setting_view.dart';
import 'package:menuloq/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:menuloq/features/main_navigation/presentation/widgets/mobile_bottom_navbar.dart';

import '../../../../config/theme/app_colors.dart';
import '../cubit/main_navigation_cubit.dart';
import '../widgets/tablet_side_nav_bar.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final di = DependencyFactory.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider<MainNavigationCubit>(create: (_) => MainNavigationCubit()),
        BlocProvider<BusinessSettingsBloc>(
          create: (_) =>
              di.createBusinessSettingsBloc()
                ..add(const BusinessSettingsStarted()),
        ),
        BlocProvider<MyAccountBloc>(
          create: (_) =>
              di.createMyAccountBloc()..add(const MyAccountStarted()),
        ),
      ],
      child: const MainShellView(),
    );
  }
}

class MainShellView extends StatelessWidget {
  const MainShellView({super.key});

  static const double _tabletBreakpoint = 720;

  static const List<NavBarItemData> _items = [
    NavBarItemData(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    NavBarItemData(
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    NavBarItemData(
      label: 'Menu',
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu_rounded,
    ),
    NavBarItemData(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
    ),
    NavBarItemData(
      label: 'Account',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  static const List<Widget> _pages = [
    DashboardView(),
    _DemoPage(title: 'Orders'),
    _DemoPage(title: 'Menu'),
    BusinessSettingsView(),
    MyAccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= _tabletBreakpoint;

        return BlocBuilder<MainNavigationCubit, int>(
          builder: (context, selectedIndex) {
            if (isTablet) {
              return Scaffold(
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.background,
                body: SafeArea(
                  child: Row(
                    children: [
                      TabletSideNavBar(
                        items: _items,
                        selectedIndex: selectedIndex,
                        onTap: context.read<MainNavigationCubit>().changeTab,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: selectedIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              extendBody: true,
              backgroundColor: isDark
                  ? AppColors.darkBackground
                  : AppColors.background,
              body: SafeArea(
                bottom: false,
                child: IndexedStack(index: selectedIndex, children: _pages),
              ),
              bottomNavigationBar: MobileBottomNavBar(
                items: _items,
                selectedIndex: selectedIndex,
                onTap: context.read<MainNavigationCubit>().changeTab,
              ),
            );
          },
        );
      },
    );
  }
}

class NavBarItemData {
  const NavBarItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _DemoPage extends StatelessWidget {
  const _DemoPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
