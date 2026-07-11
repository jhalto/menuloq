import '../entities/categories_page_entity.dart';
import '../repositories/categories_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<CategoriesPageEntity> call({
    required String query,
    int perPage = 10,
  }) {
    return _repository.getCategories(query: query, perPage: perPage);
  }
}
