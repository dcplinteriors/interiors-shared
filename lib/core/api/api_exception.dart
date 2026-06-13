/// A failed API call, carrying the HTTP status and a user-presentable message
/// (mapped from the backend's `{ error: { message } }` envelope).
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
