import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/core/di/dependency_factory.dart';
import 'package:menuloq/core/global/app_toast.dart';
import 'package:menuloq/core/utils/loader.dart';
import 'package:menuloq/features/account/presentation/bloc/my_account_bloc.dart';
import 'package:menuloq/features/account/presentation/bloc/my_account_event.dart';
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';
import 'package:menuloq/features/business_setting/domain/params/update_business_settings_params.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/business_profile_card.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/business_setting_text_field.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/field_label.dart';

import '../../../../config/theme/app_colors.dart';
import '../bloc/business_settings_bloc.dart';
import '../bloc/business_settings_event.dart';
import '../bloc/business_settings_state.dart';

class BusinessSettingsView extends StatelessWidget {
  const BusinessSettingsView({
    super.key,
    this.showHeader = true,
  });

  static const double _tabletBreakpoint = 720;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<BusinessSettingsBloc, BusinessSettingsState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.message != current.message;
      },
      listener: (context, state) {
        if (state.status == BusinessSettingsStatus.failure &&
            state.message != null) {
          AppToast.error(context, message: state.message!);
        }

        if (state.status == BusinessSettingsStatus.success &&
            state.message != null) {
          AppToast.success(context, message: state.message!);
          context.read<MyAccountBloc>().add(
            const MyAccountRefreshRequested(),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= _tabletBreakpoint;

              return Column(
                children: [
                  if (showHeader) const _BusinessSettingsHeader(),
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
      await DependencyFactory.instance.logout();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoggingOut = false);

      AppToast.error(context, message: 'Logout failed. Please try again.');
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

class _OrderDeliverySettingsCard extends StatefulWidget {
  const _OrderDeliverySettingsCard({required this.settings});

  final BusinessSettingsEntity settings;

  @override
  State<_OrderDeliverySettingsCard> createState() =>
      _OrderDeliverySettingsCardState();
}

class _OrderDeliverySettingsCardState
    extends State<_OrderDeliverySettingsCard> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryChargeController = TextEditingController();
  final _instructionsController = TextEditingController();
  late Set<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _fillFromSettings();
  }

  @override
  void didUpdateWidget(covariant _OrderDeliverySettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) _fillFromSettings();
  }

  void _fillFromSettings() {
    _deliveryChargeController.text =
        widget.settings.deliverySetting.deliveryCharge.toStringAsFixed(2);
    _instructionsController.text =
        widget.settings.deliverySetting.instructions ?? '';
    _selectedOptions = widget.settings.business.deliveryOptions.toSet();
  }

  @override
  void dispose() {
    _deliveryChargeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<BusinessSettingsBloc>().add(
      BusinessSettingsSaveRequested(
        UpdateBusinessSettingsParams.fromSettings(
          widget.settings,
          deliveryOptions: _selectedOptions.toList(),
          deliveryCharge:
              double.tryParse(_deliveryChargeController.text.trim()) ?? 0,
          instructions: _instructionsController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select(
      (BusinessSettingsBloc bloc) => bloc.state.isSaving,
    );
    final fieldErrors = context.select(
      (BusinessSettingsBloc bloc) => bloc.state.fieldErrors,
    );
    final options = widget.settings.options;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _SettingsCard(
            title: 'Order & Delivery',
            children: [
              const FieldLabel(text: 'Delivery charge'),
              const SizedBox(height: 8),
              BusinessSettingTextField(
                controller: _deliveryChargeController,
                enabled: !isSaving,
                hintText: 'Enter delivery charge',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid delivery charge.';
                  }
                  return null;
                },
                serverError: fieldErrors['delivery_charge'],
                onChanged: (_) {
                  context.read<BusinessSettingsBloc>().add(
                    const BusinessSettingsFieldsChanged(),
                  );
                },
              ),
              const SizedBox(height: 20),
              const FieldLabel(text: 'Delivery instructions'),
              const SizedBox(height: 8),
              BusinessSettingTextField(
                controller: _instructionsController,
                enabled: !isSaving,
                hintText: 'Add delivery instructions',
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                serverError: fieldErrors['instructions'],
                onChanged: (_) {
                  context.read<BusinessSettingsBloc>().add(
                    const BusinessSettingsFieldsChanged(),
                  );
                },
              ),
              const SizedBox(height: 22),
              const FieldLabel(text: 'Enabled order options'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.deliveryOptions.map((option) {
                  final selected = _selectedOptions.contains(option);

                  return FilterChip(
                    selected: selected,
                    label: Text(option),
                    onSelected: isSaving
                        ? null
                        : (value) {
                            setState(() {
                              value
                                  ? _selectedOptions.add(option)
                                  : _selectedOptions.remove(option);
                            });
                            context.read<BusinessSettingsBloc>().add(
                              const BusinessSettingsFieldsChanged(),
                            );
                          },
                    selectedColor: AppColors.accent.withAlpha(45),
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),
              if (fieldErrors['delivery_options'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  fieldErrors['delivery_options']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          _SettingsSaveButton(isSaving: isSaving, onPressed: _save),
        ],
      ),
    );
  }
}

class _RegionalSettingsCard extends StatefulWidget {
  const _RegionalSettingsCard({required this.settings});

  final BusinessSettingsEntity settings;

  @override
  State<_RegionalSettingsCard> createState() => _RegionalSettingsCardState();
}

class _RegionalSettingsCardState extends State<_RegionalSettingsCard> {
  late String _country;
  late String _currency;
  late String _timezone;
  late String _language;

  @override
  void initState() {
    super.initState();
    _fillFromSettings();
  }

  @override
  void didUpdateWidget(covariant _RegionalSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) _fillFromSettings();
  }

  void _fillFromSettings() {
    final business = widget.settings.business;
    _country = business.country;
    _currency = business.currency;
    _timezone = business.timezone;
    _language = business.websiteDefaultLanguage;
  }

  void _save() {
    context.read<BusinessSettingsBloc>().add(
      BusinessSettingsSaveRequested(
        UpdateBusinessSettingsParams.fromSettings(
          widget.settings,
          country: _country,
          currency: _currency,
          timezone: _timezone,
          websiteDefaultLanguage: _language,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = widget.settings.business;
    final options = widget.settings.options;
    final isSaving = context.select(
      (BusinessSettingsBloc bloc) => bloc.state.isSaving,
    );
    final fieldErrors = context.select(
      (BusinessSettingsBloc bloc) => bloc.state.fieldErrors,
    );

    return Column(
      children: [
        _SettingsCard(
          title: 'Regional Settings',
          children: [
            _AppDropdownField(
              label: 'Country',
              value: _country,
              items: options.countries,
              enabled: !business.countryLocked && !isSaving,
              locked: business.countryLocked,
              errorText: fieldErrors['country'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _country = value);
                  context.read<BusinessSettingsBloc>().add(
                    const BusinessSettingsFieldsChanged(),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            _AppDropdownField(
              label: 'Currency',
              value: _currency,
              items: options.currencies,
              enabled: !business.currencyLocked && !isSaving,
              locked: business.currencyLocked,
              errorText: fieldErrors['currency'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _currency = value);
                  context.read<BusinessSettingsBloc>().add(
                    const BusinessSettingsFieldsChanged(),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            _AppDropdownField(
              label: 'Timezone',
              value: _timezone,
              items: options.timezones,
              enabled: !isSaving,
              errorText: fieldErrors['timezone'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _timezone = value);
                  context.read<BusinessSettingsBloc>().add(
                    const BusinessSettingsFieldsChanged(),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            _LanguageDropdownField(
              value: _language,
              languages: options.languages,
              enabled: !isSaving,
              errorText: fieldErrors['website_default_language'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _language = value);
                  context.read<BusinessSettingsBloc>().add(
                    const BusinessSettingsFieldsChanged(),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SettingsSaveButton(isSaving: isSaving, onPressed: _save),
      ],
    );
  }
}

class _AvailabilitySettingsCard extends StatefulWidget {
  const _AvailabilitySettingsCard({required this.settings});

  final BusinessSettingsEntity settings;

  @override
  State<_AvailabilitySettingsCard> createState() =>
      _AvailabilitySettingsCardState();
}

class _AvailabilitySettingsCardState
    extends State<_AvailabilitySettingsCard> {
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.settings.business.isAvailable;
  }

  @override
  void didUpdateWidget(covariant _AvailabilitySettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _isAvailable = widget.settings.business.isAvailable;
    }
  }

  void _save() {
    context.read<BusinessSettingsBloc>().add(
      BusinessSettingsSaveRequested(
        UpdateBusinessSettingsParams.fromSettings(
          widget.settings,
          isAvailable: _isAvailable,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select(
      (BusinessSettingsBloc bloc) => bloc.state.isSaving,
    );
    final fieldErrors = context.select(
      (BusinessSettingsBloc bloc) => bloc.state.fieldErrors,
    );

    return Column(
      children: [
        _AvailabilitySwitchCard(
          isAvailable: _isAvailable,
          onChanged: isSaving
              ? (_) {}
              : (value) {
                  setState(() => _isAvailable = value);
                  context.read<BusinessSettingsBloc>().add(
                    const BusinessSettingsFieldsChanged(),
                  );
                },
        ),
        if (fieldErrors['is_available'] != null) ...[
          const SizedBox(height: 8),
          Text(
            fieldErrors['is_available']!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 22),
        _SettingsSaveButton(isSaving: isSaving, onPressed: _save),
      ],
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

class _SettingsSaveButton extends StatelessWidget {
  const _SettingsSaveButton({
    required this.isSaving,
    required this.onPressed,
  });

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(isSaving ? 'Saving...' : 'Save changes'),
        style: ElevatedButton.styleFrom(
          disabledForegroundColor: AppColors.white,
        ),
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
    this.errorText,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool locked;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedValue = items.containsKey(value) ? value : null;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final fillColor = isDark ? AppColors.darkFill : AppColors.fill;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final menuColor = isDark ? AppColors.darkCard : AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          menuMaxHeight: 340,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: menuColor,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: mutedColor),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          hint: Text(
            'Select ${label.toLowerCase()}',
            style: theme.textTheme.bodyLarge?.copyWith(color: mutedColor),
          ),
          onChanged: enabled ? onChanged : null,
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: entry.key == selectedValue
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            prefixIcon: Icon(_dropdownFieldIcon(label), color: mutedColor),
            suffixIcon: locked
                ? Icon(Icons.lock_outline_rounded, color: mutedColor)
                : null,
            filled: true,
            fillColor: fillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor.withAlpha(150)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkAccent : AppColors.accent,
                width: 1.5,
              ),
            ),
            errorText: errorText,
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
    this.enabled = true,
    this.errorText,
  });

  final String value;
  final Map<String, LanguageOptionEntity> languages;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedValue = languages.containsKey(value) ? value : null;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final fillColor = isDark ? AppColors.darkFill : AppColors.fill;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(text: 'Website default language'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          menuMaxHeight: 340,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: isDark ? AppColors.darkCard : AppColors.surface,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: mutedColor),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          hint: Text(
            'Select language',
            style: theme.textTheme.bodyLarge?.copyWith(color: mutedColor),
          ),
          onChanged: enabled ? onChanged : null,
          items: languages.entries.map((entry) {
            final language = entry.value;

            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                children: [
                  if (language.flag.trim().isNotEmpty) ...[
                    Text(
                      language.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      '${language.name} (${entry.key})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: entry.key == selectedValue
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.translate_rounded, color: mutedColor),
            filled: true,
            fillColor: fillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor.withAlpha(150)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkAccent : AppColors.accent,
                width: 1.5,
              ),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

IconData _dropdownFieldIcon(String label) {
  switch (label) {
    case 'Country':
      return Icons.public_rounded;
    case 'Currency':
      return Icons.payments_outlined;
    case 'Timezone':
      return Icons.schedule_rounded;
    default:
      return Icons.tune_rounded;
  }
}
