import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/features/categories/domain/params/create_category_params.dart';
import 'package:menuloq/features/categories/domain/usecases/create_category_use_case.dart';
import 'package:menuloq/features/categories/domain/usecases/get_categories_use_case.dart';

import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({
    required GetCategoriesUseCase getCategoriesUseCase,
    required CreateCategoryUseCase createCategoryUseCase,
  })
      : _getCategoriesUseCase = getCategoriesUseCase,
        _createCategoryUseCase = createCategoryUseCase,
        super(const CategoriesState());

  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;

  Future<void> load({
    String? query,
    int? perPage,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextPerPage = perPage ?? state.perPage;
    final effectiveQuery = nextQuery.isEmpty ? 'beverage' : nextQuery;

    emit(
      state.copyWith(
        status: CategoriesStatus.loading,
        query: effectiveQuery,
        perPage: nextPerPage,
        clearMessage: true,
      ),
    );

    try {
      final page = await _getCategoriesUseCase(
        query: effectiveQuery,
        perPage: nextPerPage,
      );

      emit(
        state.copyWith(
          status: CategoriesStatus.success,
          categories: page.categories,
          currentPage: page.currentPage,
          perPage: page.perPage,
          total: page.total,
          lastPage: page.lastPage,
          clearMessage: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          message: 'Something went wrong while loading categories.',
        ),
      );
    }
  }

  Future<void> refresh() {
    return load(query: state.query, perPage: state.perPage);
  }

  Future<void> createCategory(CreateCategoryParams params) async {
    emit(
      state.copyWith(
        createStatus: CategoryCreateStatus.loading,
        clearCreateMessage: true,
        clearFieldErrors: true,
      ),
    );

    try {
      final message = await _createCategoryUseCase(params);

      emit(
        state.copyWith(
          createStatus: CategoryCreateStatus.success,
          createMessage: message,
          clearFieldErrors: true,
        ),
      );

      await refresh();
    } on AppException catch (error) {
      emit(
        state.copyWith(
          createStatus: CategoryCreateStatus.failure,
          createMessage: error.message,
          fieldErrors: _firstValidationErrors(error.errors),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          createStatus: CategoryCreateStatus.failure,
          createMessage: 'Something went wrong while creating category.',
        ),
      );
    }
  }

  void clearCreateState() {
    emit(
      state.copyWith(
        createStatus: CategoryCreateStatus.initial,
        clearCreateMessage: true,
        clearFieldErrors: true,
      ),
    );
  }

  Map<String, String> _firstValidationErrors(
    Map<String, List<String>>? errors,
  ) {
    if (errors == null || errors.isEmpty) return const {};

    return errors.map((key, value) {
      return MapEntry(key, value.isEmpty ? '' : value.first);
    });
  }
}
