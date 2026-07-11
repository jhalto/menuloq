import '../entities/categories_page_entity.dart';
import '../params/create_category_params.dart';

abstract class CategoriesRepository {
  Future<CategoriesPageEntity> getCategories({
    required String query,
    required int perPage,
  });

  Future<String> createCategory(CreateCategoryParams params);
}
