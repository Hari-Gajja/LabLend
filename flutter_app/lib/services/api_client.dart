import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/api_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Always ensure options baseUrl is up to date with config
          options.baseUrl = ApiConfig.baseUrl;

          final token = await _storage.read(key: AppConstants.tokenStorageKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final transformed = _mapDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: transformed,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;

  AppFailure _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkFailure(
        'Unable to connect to LabLend server. Please ensure the backend is running and reachable.',
      );
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;

      String message = 'An unexpected server error occurred';
      String code = 'UNKNOWN_ERROR';
      List<dynamic>? errors;

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        code = data['code'] ?? code;
        errors = data['errors'];
      }

      if (statusCode == 401) {
        return UnauthorizedFailure(message);
      } else if (statusCode == 400) {
        return ValidationFailure(message, errors: errors);
      } else if (statusCode == 409) {
        return ConflictFailure(message);
      }

      return AppFailure(
        message: message,
        code: code,
        statusCode: statusCode,
        errors: errors,
      );
    }

    return AppFailure(message: error.message ?? 'Unknown request error');
  }

  // Helper wrappers
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      if (e.error is AppFailure) throw e.error!;
      throw AppFailure(message: e.message ?? 'Request failed');
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      if (e.error is AppFailure) throw e.error!;
      throw AppFailure(message: e.message ?? 'Request failed');
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      if (e.error is AppFailure) throw e.error!;
      throw AppFailure(message: e.message ?? 'Request failed');
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      if (e.error is AppFailure) throw e.error!;
      throw AppFailure(message: e.message ?? 'Request failed');
    }
  }
}
