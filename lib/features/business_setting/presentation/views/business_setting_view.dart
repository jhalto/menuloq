import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/core/di/dependency_factory.dart';
import 'package:menuloq/core/utils/loader.dart';
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/business_profile_card.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/business_setting_text_field.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/field_label.dart';

import '../../../../config/theme/app_colors.dart';
import '../bloc/business_settings_bloc.dart';
import '../bloc/business_settings_event.dart';
import '../bloc/business_settings_state.dart';

class BusinessSettingsView extends StatelessWidget {
  const BusinessSettingsView({super.key});

  static const double _tabletBreakpoint = 720;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= _tabletBreakpoint;

            return Column(
              children: [
                const _BusinessSettingsHeader(),
                const _SettingsTabBar(),
                Expanded(
                  child: BlocBuilder<BusinessSettingsBloc, BusinessSettingsState>(
                    buildWhen: (previous, current) =>
                        previous.status != current.status ||
                        previous.settings != current.settings,
                    builder: (context, state) {
                      if (state.isLoading && !state.hasSettings) {
                        return const Center(child: Loader());
                      }

                      if (state.status == BusinessSettingsStatus.failure &&
                          !state.hasSettings) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.message ??
                                      'Failed to load business settings.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<BusinessSettingsBloc>().add(
                                      const BusinessSettingsRefreshRequested(),
                                    );
                                  },
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 32 : 12,
                          22,
                          isTablet ? 32 : 12,
                          28,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 900 : 430,
                            ),
                            child: const _SettingsTabContent(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BusinessSettingsHeader extends StatefulWidget {
  const _BusinessSettingsHeader();

  @override
  State<_BusinessSettingsHeader> createState() =>
      _BusinessSettingsHeaderState();
}

class _BusinessSettingsHeaderState extends State<_BusinessSettingsHeader> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    setState(() => _isLoggingOut = true);

    try {
      await DependencyFactory.instance.authRepository.logout();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoggingOut = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Text(
                'Business Settings',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Manage your business information and order preferences.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<String>(
              enabled: !_isLoggingOut,
              color: isDark ? AppColors.darkCard : AppColors.surface,
              icon: _isLoggingOut
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.more_vert_rounded, color: titleColor),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTabBar extends StatelessWidget {
  const _SettingsTabBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessSettingsBloc, BusinessSettingsState>(
      buildWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBackground
                : AppColors.background,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              _SettingsTabButton(
                tab: BusinessSettingsTab.profile,
                selectedTab: state.selectedTab,
                icon: Icons.person_outline_rounded,
                label: 'Profile',
              ),
              _SettingsTabButton(
                tab: BusinessSettingsTab.regional,
                selectedTab: state.selectedTab,
                icon: Icons.language_rounded,
                label: 'Regional',
              ),
              _SettingsTabButton(
                tab: BusinessSettingsTab.orderDelivery,
                selectedTab: state.selectedTab,
                icon: Icons.delivery_dining_rounded,
                label: 'Order & Delivery',
              ),
              _SettingsTabButton(
                tab: BusinessSettingsTab.availability,
                selectedTab: state.selectedTab,
                icon: Icons.schedule_rounded,
                label: 'Availability',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTabButton extends StatelessWidget {
  const _SettingsTabButton({
    required this.tab,
    required this.selectedTab,
    required this.icon,
    required this.label,
  });

  final BusinessSettingsTab tab;
  final BusinessSettingsTab selectedTab;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isSelected = tab == selectedTab;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = AppColors.accent;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () {
          context.read<BusinessSettingsBloc>().add(
            BusinessSettingsTabChanged(tab),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 3,
                color: isSelected ? activeColor : Colors.transparent,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 30,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? activeColor : inactiveColor,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTabContent extends StatelessWidget {
  const _SettingsTabContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessSettingsBloc, BusinessSettingsState>(
      buildWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab ||
          previous.settings != current.settings ||
          previous.status != current.status,
      builder: (context, state) {
        final settings = state.settings;

        if (settings == null) {
          return const SizedBox.shrink();
        }

        switch (state.selectedTab) {
          case BusinessSettingsTab.profile:
            return BusinessProfileCard(settings: settings);

          case BusinessSettingsTab.regional:
            return _RegionalSettingsCard(settings: settings);

          case BusinessSettingsTab.orderDelivery:
            return _OrderDeliverySettingsCard(settings: settings);

          case BusinessSettingsTab.availability:
            return _AvailabilitySettingsCard(settings: settings);
        }
      },
    );
  }
}

class _OrderDeliverySettingsCard extends StatelessWidget {
  const _OrderDeliverySettingsCard({required this.settings});

  final BusinessSettingsEntity settings;

  @override
  Widget build(BuildContext context) {
    final business = settings.business;
    final deliverySetting = settings.deliverySetting;
    final options = settings.options;

    return _SettingsCard(
      title: 'Order & Delivery',
      children: [
        _ReadOnlyField(
          label: 'Delivery charge',
          value: deliverySetting.deliveryCharge.toStringAsFixed(2),
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: 20),
        _ReadOnlyField(
          label: 'Delivery instructions',
          value: deliverySetting.instructions?.trim().isNotEmpty == true
              ? deliverySetting.instructions!
              : 'No instructions added',
          icon: Icons.notes_rounded,
        ),
        const SizedBox(height: 22),
        FieldLabel(text: 'Enabled order options'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.deliveryOptions.map((option) {
            final selected = business.deliveryOptions.contains(option);

            return FilterChip(
              selected: selected,
              label: Text(option),
              onSelected: (_) {},
              selectedColor: AppColors.accent.withAlpha(45),
              checkmarkColor: AppColors.accent,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RegionalSettingsCard extends StatelessWidget {
  const _RegionalSettingsCard({required this.settings});

  final BusinessSettingsEntity settings;

  @override
  Widget build(BuildContext context) {
    final business = settings.business;
    final options = settings.options;

    return _SettingsCard(
      title: 'Regional Settings',
      children: [
        _AppDropdownField(
          label: 'Country',
          value: business.country,
          items: options.countries,
          enabled: !business.countryLocked,
          locked: business.countryLocked,
          onChanged: (_) {},
        ),
        const SizedBox(height: 20),
        _AppDropdownField(
          label: 'Currency',
          value: business.currency,
          items: options.currencies,
          enabled: !business.currencyLocked,
          locked: business.currencyLocked,
          onChanged: (_) {},
        ),
        const SizedBox(height: 20),
        _AppDropdownField(
          label: 'Timezone',
          value: business.timezone,
          items: options.timezones,
          enabled: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: 20),
        _LanguageDropdownField(
          value: business.websiteDefaultLanguage,
          languages: options.languages,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _AvailabilitySettingsCard extends StatelessWidget {
  const _AvailabilitySettingsCard({required this.settings});

  final BusinessSettingsEntity settings;

  @override
  Widget build(BuildContext context) {
    final business = settings.business;

    return _AvailabilitySwitchCard(
      isAvailable: business.isAvailable,
      onChanged: (_) {},
    );
  }
}

class _AvailabilitySwitchCard extends StatelessWidget {
  const _AvailabilitySwitchCard({
    required this.isAvailable,
    required this.onChanged,
  });

  final bool isAvailable;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkFill : AppColors.fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable
                ? Icons.check_circle_outline_rounded
                : Icons.pause_circle_outline_rounded,
            color: isAvailable ? AppColors.accent : subtitleColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business availability',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAvailable
                      ? 'Your business is currently available for orders.'
                      : 'Your business is currently unavailable for orders.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isAvailable,
            activeColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }
}

class _AppDropdownField extends StatelessWidget {
  const _AppDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.locked = false,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final selectedValue = items.containsKey(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          onChanged: enabled ? onChanged : null,
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          decoration: InputDecoration(
            suffixIcon: locked ? const Icon(Icons.lock_outline_rounded) : null,
          ),
        ),
      ],
    );
  }
}

class _LanguageDropdownField extends StatelessWidget {
  const _LanguageDropdownField({
    required this.value,
    required this.languages,
    required this.onChanged,
  });

  final String value;
  final Map<String, LanguageOptionEntity> languages;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = languages.containsKey(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(text: 'Website default language'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          onChanged: onChanged,
          items: languages.entries.map((entry) {
            final language = entry.value;

            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                '${language.name} (${entry.key})',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 8),
        BusinessSettingTextField(
          controller: controller,
          enabled: false,
          readOnly: true,
          hintText: label,
          suffixIcon: icon,
        ),
      ],
    );
  }
}
