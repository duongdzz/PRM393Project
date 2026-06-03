import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginController extends GetxController {
  final isLoading    = false.obs;
  final errorMessage = ''.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value    = true;
      errorMessage.value = '';

      // Giả lập loading 1.5 giây
      await Future.delayed(const Duration(milliseconds: 1500));

      if (kIsWeb) {
        // ── Test trên Chrome: mock data ──────────────────────────────────────
        await AuthService.to.saveSession(
          newToken:     'web_mock_token_123',
          newUserId:    '1',
          newUserName:  'Người dùng Test',
          newUserEmail: 'test@gmail.com',
          newPhotoUrl:  '',
        );
      } else {
        // ── Android/iOS: sẽ thêm Google Sign-In sau ─────────────────────────
        await AuthService.to.saveSession(
          newToken:     'android_mock_token',
          newUserId:    '1',
          newUserName:  'Người dùng',
          newUserEmail: 'user@gmail.com',
          newPhotoUrl:  '',
        );
      }

      Get.offAllNamed(AppRoutes.home);

    } catch (e) {
      errorMessage.value = 'Đăng nhập thất bại: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}