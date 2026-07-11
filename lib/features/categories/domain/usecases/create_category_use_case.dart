import '../params/create_category_params.dart';
import '../repositories/categories_repository.dart';

class CreateCategoryUseCase {
  const CreateCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<String> call(CreateCategoryParams params) {
    return _repository.createCategory(params);
  }
}
