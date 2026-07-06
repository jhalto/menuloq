class MyAccountValidationException implements Exception {
  const MyAccountValidationException({
    required this.message,
    required this.errors,
  });

  final String message;
  final Map<String, String> errors;

  @override
  String toString() => message;
}