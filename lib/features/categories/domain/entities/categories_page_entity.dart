import 'category_entity.dart';

class CategoriesPageEntity {
  const CategoriesPageEntity({
    required this.categories,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final List<CategoryEntity> categories;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
}
