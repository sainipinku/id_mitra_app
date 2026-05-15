class ApiResult {
  final bool status;
  final int statusCode;
  final dynamic data;
  final String message;

  ApiResult({
    required this.status,
    required this.statusCode,
    this.data,
    required this.message,
  });
}
