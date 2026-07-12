import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'auth_service.dart';

// ── Custom Exception ──────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

// ── ApiService ────────────────────────────────────────────────────────────────
class ApiService extends GetxService {
  static ApiService get to => Get.find<ApiService>();

  late final Dio _dio;

  static const String baseUrl = 'http://192.168.0.104:5000';

  Future<ApiService> init() async {
    _dio = Dio(BaseOptions(
      baseUrl:        baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final auth = AuthService.to;
        if (auth.useApi && auth.token.value.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${auth.token.value}';
        }
        handler.next(options);
      },

      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401 && AuthService.to.useApi) {
          AuthService.to.clearSession();
          Get.offAllNamed('/login');
        }
        handler.next(e);
      },
    ));

    return this;
  }

  // ── GET ───────────────────────────────────────────────────────────────────────
  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final res = await _dio.get(path, queryParameters: params);
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── POST ──────────────────────────────────────────────────────────────────────
  Future<dynamic> post(
    String path, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: body,
        queryParameters: queryParams,
      );
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────────
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error handler ─────────────────────────────────────────────────────────────
  ApiException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException('Kết nối quá chậm, vui lòng thử lại.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException('Không thể kết nối server. Kiểm tra mạng.');
    }

    final statusCode = e.response?.statusCode;
    final message    = e.response?.data?['message']
        ?? e.response?.data?['error']
        ?? 'Lỗi không xác định ($statusCode)';

    return ApiException(message.toString());
  }
}