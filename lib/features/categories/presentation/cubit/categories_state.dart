import '../../domain/entities/category_entity.dart';

enum CategoriesStatus { initial, loading, success, failure }

enum CategoryCreateStatus { initial, loading, success, failure }

class CategoriesState {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.createStatus = CategoryCreateStatus.initial,
    this.categories = const [],
    this.query = 'beverage',
    this.perPage = 10,
    this.currentPage = 1,
    this.total = 0,
    this.lastPage = 1,
    this.message,
    this.createMessage,
    this.fieldErrors = const {},
  });

  final CategoriesStatus status;
  final CategoryCreateStatus createStatus;
  final List<CategoryEntity> categories;
  final String query;
  final int perPage;
  final int currentPage;
  final int total;
  final int lastPage;
  final String? message;
  final String? createMessage;
  final Map<String, String> fieldErrors;

  bool get isLoading => status == CategoriesStatus.loading;
  bool get isCreating => createStatus == CategoryCreateStatus.loading;

  CategoriesState copyWith({
    CategoriesStatus? status,
    CategoryCreateStatus? createStatus,
    List<CategoryEntity>? categories,
    String? query,
    int? perPage,
    int? currentPage,
    int? total,
    int? lastPage,
    String? message,
    String? createMessage,
    Map<String, String>? fieldErrors,
    bool clearMessage = false,
    bool clearCreateMessage = false,
    bool clearFieldErrors = false,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      createStatus: createStatus ?? this.createStatus,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      perPage: perPage ?? this.perPage,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      lastPage: lastPage ?? this.lastPage,
      message: clearMessage ? null : message ?? this.message,
      createMessage:
          clearCreateMessage ? null : createMessage ?? this.createMessage,
      fieldErrors: clearFieldErrors ? const {} : fieldErrors ?? this.fieldErrors,
    );
  }
}
