import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/core/global/app_toast.dart';
import 'package:menuloq/core/utils/loader.dart';
import 'package:menuloq/features/categories/domain/entities/category_entity.dart';
import 'package:menuloq/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:menuloq/features/categories/presentation/cubit/categories_state.dart';
import 'package:menuloq/features/categories/presentation/views/add_category_view.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({
    super.key,
    this.showHeader = true,
  });

  final bool showHeader;

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'beverage');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    context.read<CategoriesCubit>().load(
          query: _searchController.text,
          perPage: 10,
        );
  }

  void _openAddCategory() {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CategoriesCubit>(),
          child: const AddCategoryView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<CategoriesCubit, CategoriesState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.message != current.message;
      },
      listener: (context, state) {
        if (state.status == CategoriesStatus.failure &&
            state.message != null) {
          AppToast.error(context, message: state.message!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddCategory,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Category'),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 720;
                final horizontalPadding = isTablet ? 32.0 : 14.0;

                return RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: () => context.read<CategoriesCubit>().refresh(),
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (widget.showHeader)
                        SliverToBoxAdapter(child: _Header(isTablet: isTablet)),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          18,
                          horizontalPadding,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _SearchPanel(
                            controller: _searchController,
                            enabled: !state.isLoading,
                            total: state.total,
                            currentPage: state.currentPage,
                            lastPage: state.lastPage,
                            query: state.query,
                            onSearch: _search,
                            onAdd: _openAddCategory,
                            onRefresh: () {
                              context.read<CategoriesCubit>().refresh();
                            },
                          ),
                        ),
                      ),
                      if (state.isLoading && state.categories.isNotEmpty)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            12,
                            horizontalPadding,
                            0,
                          ),
                          sliver: const SliverToBoxAdapter(
                            child: LinearProgressIndicator(
                              minHeight: 3,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      if (state.isLoading && state.categories.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Loader()),
                        )
                      else if (state.categories.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(
                            message: state.status == CategoriesStatus.failure
                                ? state.message ??
                                    'Failed to load categories.'
                                : 'No categories found for this search.',
                            onRetry: () {
                              context.read<CategoriesCubit>().refresh();
                            },
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16,
                            horizontalPadding,
                            96,
                          ),
                          sliver: _CategoriesGrid(
                            categories: state.categories,
                            maxWidth: constraints.maxWidth,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 16,
        18,
        isTablet ? 32 : 16,
        14,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Browse and search menu categories from your catalog.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.enabled,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.query,
    required this.onSearch,
    required this.onAdd,
    required this.onRefresh,
  });

  final TextEditingController controller;
  final bool enabled;
  final int total;
  final int currentPage;
  final int lastPage;
  final String query;
  final VoidCallback onSearch;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSearch(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search categories',
                    prefixIcon: Icon(Icons.search_rounded, color: mutedColor),
                    filled: true,
                    fillColor: isDark ? AppColors.darkFill : AppColors.fill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: enabled ? onSearch : null,
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Search',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.textDisabled,
                  fixedSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: enabled ? onAdd : null,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add category',
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  fixedSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: enabled ? onRefresh : null,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                style: IconButton.styleFrom(
                  foregroundColor: textColor,
                  fixedSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: borderColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.category_outlined,
                label: '$total total',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.layers_outlined,
                label: 'Page $currentPage of $lastPage',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Query: $query',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccentLight : AppColors.accentLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkAccent : AppColors.accentDark,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({
    required this.categories,
    required this.maxWidth,
  });

  final List<CategoryEntity> categories;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = maxWidth >= 1120
        ? 3
        : maxWidth >= 680
            ? 2
            : 1;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _CategoryCard(category: categories[index]),
        childCount: categories.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 148,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final isActive = category.isActive != false;
    final statusColor = isActive
        ? (isDark ? AppColors.darkAccent : AppColors.accent)
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _CategoryImage(imageUrl: category.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(
                      color: statusColor,
                      label: isActive ? 'Active' : 'Inactive',
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Category ID ${category.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(
                    category.description?.trim().isNotEmpty == true
                        ? category.description!
                        : 'Ready to organize menu items under this category.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered_rounded,
                      size: 16,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.position == null
                          ? 'Position not set'
                          : 'Position ${category.position}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (category.uid != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: mutedColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'UID ${category.uid}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 82,
        height: 112,
        color: isDark ? AppColors.darkFill : AppColors.primaryLight,
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _CategoryImageFallback(),
              )
            : const _CategoryImageFallback(),
      ),
    );
  }
}

class _CategoryImageFallback extends StatelessWidget {
  const _CategoryImageFallback();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Icon(
      Icons.restaurant_menu_rounded,
      color: isDark ? AppColors.darkAccent : AppColors.accent,
      size: 34,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkFill : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category_outlined,
              color: isDark ? AppColors.darkAccent : AppColors.accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No categories to show',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mutedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
