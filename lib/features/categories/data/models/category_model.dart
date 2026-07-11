import 'package:menuloq/core/config/app_config.dart';

import '../../domain/entities/categories_page_entity.dart';
import '../../domain/entities/category_entity.dart';

class CategoriesPageModel extends CategoriesPageEntity {
  const CategoriesPageModel({
    required super.categories,
    required super.currentPage,
    required super.perPage,
    required super.total,
    required super.lastPage,
  });

  factory CategoriesPageModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : json;

    final rawCategories = dataMap['categories'];
    final categories = rawCategories is List
        ? rawCategories
            .whereType<Map>()
            .map(
              (item) => CategoryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((category) => category.name.trim().isNotEmpty)
            .toList()
        : <CategoryModel>[];

    final pagination = dataMap['pagination'];
    final paginationMap = pagination is Map
        ? Map<String, dynamic>.from(pagination)
        : const <String, dynamic>{};

    return CategoriesPageModel(
      categories: categories,
      currentPage: CategoryModel._readInt(
            paginationMap,
            const ['current_page'],
          ) ??
          1,
      perPage: CategoryModel._readInt(paginationMap, const ['per_page']) ??
          categories.length,
      total: CategoryModel._readInt(paginationMap, const ['total']) ??
          categories.length,
      lastPage:
          CategoryModel._readInt(paginationMap, const ['last_page']) ?? 1,
    );
  }
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.uid,
    super.description,
    super.imageUrl,
    super.position,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _readString(json, const ['id', 'category_id']),
      name: _readString(json, const ['name', 'category_name', 'title']),
      uid: _readInt(json, const ['uid', 'user_id']),
      description: _readNullableString(
        json,
        const ['description', 'details', 'short_description'],
      ),
      imageUrl: _normalizeImageUrl(
        _readNullableString(
          json,
          const ['image_url', 'image', 'icon', 'logo'],
        ),
      ),
      position: _readInt(json, const ['position']),
      isActive: _readBool(json, const ['is_active', 'active', 'status']),
      createdAt: _readNullableString(json, const ['created_at']),
      updatedAt: _readNullableString(json, const ['updated_at']),
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return 'Unknown';
  }

  static String? _readNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }

    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;

      final text = value?.toString().trim().toLowerCase();
      if (text == null || text.isEmpty) continue;
      if (text == 'active' || text == 'true' || text == '1') return true;
      if (text == 'inactive' || text == 'false' || text == '0') return false;
    }

    return null;
  }

  static String? _normalizeImageUrl(String? value) {
    final image = value?.trim();
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    final baseUri = Uri.tryParse(AppConfig.baseUrl);
    final origin = baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty
        ? 'https://menuloq.com'
        : baseUri.origin;

    return '$origin${image.startsWith('/') ? image : '/$image'}';
  }
}
