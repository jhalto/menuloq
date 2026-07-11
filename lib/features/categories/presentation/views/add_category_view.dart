import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/core/global/app_toast.dart';
import 'package:menuloq/core/helper/image_picker_helper.dart';
import 'package:menuloq/features/categories/domain/params/create_category_params.dart';
import 'package:menuloq/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:menuloq/features/categories/presentation/cubit/categories_state.dart';

class AddCategoryView extends StatefulWidget {
  const AddCategoryView({super.key});

  @override
  State<AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _positionController = TextEditingController(text: '1');

  PickedAppImage? _selectedImage;
  bool _isActive = true;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CategoriesCubit>().clearCreateState();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<CategoriesCubit>().createCategory(
          CreateCategoryParams(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            position: int.parse(_positionController.text.trim()),
            isActive: _isActive,
            imageBytes: _selectedImage?.bytes,
            imageFileName: _selectedImage?.fileName,
          ),
        );
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    final source = await _showImageSourcePicker();
    if (source == null || !mounted) return;

    setState(() => _isPickingImage = true);

    try {
      final image = await ImagePickerHelper.pick(
        source: source,
        maxBytes: 1024 * 1024,
        allowedExtensions: const {'jpg', 'jpeg', 'png', 'webp', 'gif'},
      );
      if (!mounted || image == null) return;

      setState(() => _selectedImage = image);
    } on ImagePickerException catch (error) {
      if (mounted) AppToast.error(context, message: error.message);
    } catch (_) {
      if (mounted) {
        AppToast.error(
          context,
          message: 'Could not select the image. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<AppImageSource?> _showImageSourcePicker() {
    final theme = Theme.of(context);

    return showModalBottomSheet<AppImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose image source',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, AppImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photo library'),
                  onTap: () => Navigator.pop(context, AppImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.background;

    return BlocListener<CategoriesCubit, CategoriesState>(
      listenWhen: (previous, current) {
        return previous.createStatus != current.createStatus ||
            previous.createMessage != current.createMessage;
      },
      listener: (context, state) {
        if (state.createStatus == CategoryCreateStatus.failure &&
            state.createMessage != null) {
          AppToast.error(context, message: state.createMessage!);
        }

        if (state.createStatus == CategoryCreateStatus.success) {
          AppToast.success(
            context,
            message: state.createMessage ?? 'Category created successfully.',
          );
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Add Category'),
        ),
        body: SafeArea(
          child: BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              final isCreating = state.isCreating;
              final errors = state.fieldErrors;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CategoryImagePicker(
                            selectedImage: _selectedImage,
                            isPicking: _isPickingImage,
                            enabled: !isCreating,
                            errorText: errors['image'],
                            onPick: _pickImage,
                          ),
                          const SizedBox(height: 16),
                          _CategoryTextField(
                            controller: _nameController,
                            enabled: !isCreating,
                            label: 'Name',
                            hintText: 'Beverages',
                            prefixIcon: Icons.category_outlined,
                            serverError: errors['name'],
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Please enter category name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _CategoryTextField(
                            controller: _descriptionController,
                            enabled: !isCreating,
                            label: 'Description',
                            hintText: 'Hot and cold drinks',
                            prefixIcon: Icons.notes_rounded,
                            serverError: errors['description'],
                            maxLines: 3,
                            textInputAction: TextInputAction.newline,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Please enter category description.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _CategoryTextField(
                            controller: _positionController,
                            enabled: !isCreating,
                            label: 'Position',
                            hintText: '1',
                            prefixIcon: Icons.format_list_numbered_rounded,
                            serverError: errors['position'],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final position =
                                  int.tryParse((value ?? '').trim());
                              if (position == null || position < 1) {
                                return 'Please enter a valid position.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _ActiveSwitch(
                            value: _isActive,
                            enabled: !isCreating,
                            errorText: errors['is_active'],
                            onChanged: (value) {
                              setState(() => _isActive = value);
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: isCreating ? null : _submit,
                              icon: isCreating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add_rounded),
                              label: Text(
                                isCreating ? 'Creating...' : 'Create Category',
                              ),
                              style: ElevatedButton.styleFrom(
                                disabledForegroundColor: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryImagePicker extends StatelessWidget {
  const _CategoryImagePicker({
    required this.selectedImage,
    required this.isPicking,
    required this.enabled,
    required this.onPick,
    this.errorText,
  });

  final PickedAppImage? selectedImage;
  final bool isPicking;
  final bool enabled;
  final VoidCallback onPick;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final fillColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 96,
              height: 96,
              color: isDark ? AppColors.darkFill : AppColors.primaryLight,
              child: selectedImage == null
                  ? Icon(
                      Icons.image_outlined,
                      color: isDark ? AppColors.darkAccent : AppColors.accent,
                      size: 34,
                    )
                  : Image.memory(
                      selectedImage!.bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Image',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedImage?.fileName ?? 'JPG, PNG, WEBP or GIF, max 1 MB',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (errorText != null && errorText!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: enabled && !isPicking ? onPick : null,
                  icon: isPicking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_rounded),
                  label: Text(isPicking ? 'Picking...' : 'Upload'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTextField extends StatelessWidget {
  const _CategoryTextField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.serverError,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final String? serverError;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final fillColor = isDark ? AppColors.darkFill : AppColors.fill;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: serverError,
        prefixIcon: Icon(prefixIcon, color: mutedColor),
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
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
      ),
    );
  }
}

class _ActiveSwitch extends StatelessWidget {
  const _ActiveSwitch({
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.errorText,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final fillColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                value
                    ? Icons.check_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                color: value ? AppColors.accent : mutedColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value ? 'is_active: 1' : 'is_active: 0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                activeColor: AppColors.accent,
                onChanged: enabled ? onChanged : null,
              ),
            ],
          ),
          if (errorText != null && errorText!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
