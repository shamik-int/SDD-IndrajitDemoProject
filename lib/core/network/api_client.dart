import 'package:dio/dio.dart';

import '../result/result.dart';

/// Thin wrapper around `dio`, returning the shared [Result] envelope so the
/// repository layer never leaks `DioException`/`Response` into `domain`.
///
/// Base URL, headers, and interceptors (auth token attachment, logging) are
/// configured per environment at app start — see `lib/app/app.dart` and
/// `assets/env/.env.*` (ADR-0001 §3).
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) => _request(
    () => _dio.get(path, queryParameters: queryParameters),
    fromJson,
  );

  Future<Result<T>> post<T>(
    String path, {
    Object? body,
    required T Function(dynamic json) fromJson,
  }) => _request(() => _dio.post(path, data: body), fromJson);

  Future<Result<T>> _request<T>(
    Future<Response> Function() call,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      final response = await call();
      return Result.success(fromJson(response.data));
    } on DioException catch (e) {
      return Result.error(_messageFor(e));
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  String _messageFor(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your connection and try again.';
    }
    final status = e.response?.statusCode;
    if (status != null && status >= 500) {
      return 'Something went wrong on our side. Please try again shortly.';
    }
    // 4xx: prefer a server-supplied message if present; never surface raw
    // payloads containing employee PII (constitution.md Security Posture).
    return e.response?.data is Map && (e.response!.data as Map)['message'] != null
        ? (e.response!.data as Map)['message'].toString()
        : 'Request could not be completed.';
  }
}
