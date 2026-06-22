import 'package:dcpl_shared/core/api/api_exception.dart';
import 'package:dcpl_shared/core/auth/token_source.dart';
import 'package:dcpl_shared/core/config/app_config.dart';
import 'package:dio/dio.dart';

/// Thin wrapper over Dio. Attaches the Firebase ID token to every request and
/// normalizes errors into [ApiException]. The single network boundary for the apps.
class ApiClient {
  ApiClient(this._tokens, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokens.idToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenSource _tokens;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() => _dio.patch(path, data: body));

  Future<dynamic> _send(Future<Response> Function() call) async {
    try {
      final res = await call();
      return res.data;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    if (data is Map &&
        data['error'] is Map &&
        data['error']['message'] is String) {
      return ApiException(status, data['error']['message'] as String);
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return ApiException(
        0,
        'Cannot reach the server. Is the backend running?',
      );
    }
    return ApiException(status, 'Something went wrong');
  }
}
