class AppException implements Exception {
  const AppException({
    required this.message,
    this.errors,
  });

  final String message;
  final Map<String, List<String>>? errors;
}
