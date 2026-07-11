import '../../domain/entities/categories_page_entity.dart';
import '../../domain/params/create_category_params.dart';
import '../../domain/repositories/categories_repository.dart';
import '../data_sources/remote/categories_remote_data_source.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  const CategoriesRepositoryImpl(this._remoteDataSource);

  final CategoriesRemoteDataSource _remoteDataSource;

  @override
  Future<CategoriesPageEntity> getCategories({
    required String query,
    required int perPage,
  }) {
    return _remoteDataSource.getCategories(query: query, perPage: perPage);
  }

  @override
  Future<String> createCategory(CreateCategoryParams params) {
    return _remoteDataSource.createCategory(params);
  }
}
