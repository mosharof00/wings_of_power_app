import 'package:dio/dio.dart';

import 'api_endpoints.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? path;

  ApiException(this.message, {this.statusCode, this.path});

  /// 401 from an auth endpoint means bad credentials, not an expired session.
  bool get isAuthRequest => ApiEndpoint.isAuthPath(path);

  factory ApiException.fromDio(DioException e) {
    final path = e.requestOptions.uri.toString();

    if (e.type == DioExceptionType.connectionTimeout) {
      return ApiException("Connection timeout", path: path);
    }

    if (e.type == DioExceptionType.badResponse) {
      return ApiException(
        _messageFrom(e.response?.data),
        statusCode: e.response?.statusCode,
        path: path,
      );
    }

    if (e.type == DioExceptionType.unknown ||
        e.type == DioExceptionType.connectionError) {
      return ApiException("No Internet connection", path: path);
    }
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException("Request timed out", path: path);
    }
    if (e.type == DioExceptionType.cancel) {
      return ApiException("Request was cancelled", path: path);
    }

    return ApiException("Something went wrong", path: path);
  }

  /// Prefers the first field-level validation message over the generic one.
  static String _messageFrom(dynamic data) {
    if (data is String && data.isNotEmpty) return data;
    if (data is! Map) return "Server error";

    final details = data['details'];
    if (details is List && details.isNotEmpty) {
      final first = details.first;
      if (first is Map && first['message'] is String) {
        return first['message'] as String;
      }
    }
    return data['message']?.toString() ?? "Server error";
  }
}
