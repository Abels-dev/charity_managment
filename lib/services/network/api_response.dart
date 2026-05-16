class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.data,
    this.message,
  });

  final int statusCode;
  final T data;
  final String? message;
}
