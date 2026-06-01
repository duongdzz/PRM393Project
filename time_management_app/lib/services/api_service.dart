import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'auth_service.dart';

// ── Custom Exception ──────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int?   statusCode;
  ApiException(this.message, {this.statusCode});
}

// ── ApiService ────────────────────────────────────────────────────────────────
class ApiService extends GetxService {
  static ApiService get to => Get.find<ApiService>();

  late final Dio _dio;

  // TODO: Đổi thành IP/domain thật của máy chạy ASP.NET
  // Chạy trên Android emulator  → 10.0.2.2
  // Chạy trên máy thật (Wi-Fi)  → IP máy tính, ví dụ 192.168.1.5
  // Đã deploy lên server        → https://yourdomain.com

  //static const String baseUrl = 'http://10.0.2.2:5000';

  static const String baseUrl = 'http://localhost:56473';

  Future<ApiService> init() async {
    _dio = Dio(BaseOptions(
      baseUrl:        baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // Interceptor: tự động gắn JWT token vào mọi request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AuthService.to.token.value;
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },

      onError: (DioException e, handler) {
        // Token hết hạn → đăng xuất
        if (e.response?.statusCode == 401) {
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
  Future<dynamic> post(String path, {required Map<String, dynamic> body}) async {
    try {
      final res = await _dio.post(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── PUT ───────────────────────────────────────────────────────────────────────
  Future<dynamic> put(String path, {required Map<String, dynamic> body}) async {
    try {
      final res = await _dio.put(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────────
  Future<dynamic> delete(String path) async {
    try {
      final res = await _dio.delete(path);
      return res.data;
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

    return ApiException(message.toString(), statusCode: statusCode);
  }
}