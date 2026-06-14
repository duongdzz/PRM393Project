import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginController extends GetxController {
  final isLoading    = false.obs;
  final errorMessage = ''.obs;


  static const String _serverClientId = '902695750711-t8053eb25qkq2spsaff9ki1710tpu4n5.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  /// Vào app xem thử không cần đăng nhập Google.
  Future<void> signInAsGuest() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await AuthService.to.saveSession(
        newToken:     'guest_token',
        newUserId:    'guest',
        newUserName:  'Khách',
        newUserEmail: '',
        newPhotoUrl:  '',
      );
      Get.offAllNamed(AppRoutes.home);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value    = true;
      errorMessage.value = '';

      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 800));
        await AuthService.to.saveSession(
          newToken:     'web_mock_token_123',
          newUserId:    '1',
          newUserName:  'Em Dương Đang test',
          newUserEmail: 'test@gmail.com',
          newPhotoUrl:  '',
        );
        Get.offAllNamed(AppRoutes.home);
        return;
      }

      // Android/iOS: Google Sign-In thật 
      await _initializeGoogleSignIn();
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      
      final GoogleSignInAuthentication auth = account.authentication;
      
      // idToken chỉ có khi cấu hình serverClientId/Web OAuth client.
      // Fallback account.id giúp app lưu session local trong giai đoạn chưa có backend.
      final String sessionToken = auth.idToken ?? account.id;
      
      await AuthService.to.saveSession(
        newToken:     sessionToken,
        newUserId:    account.id,
        newUserName:  account.displayName ?? '',
        newUserEmail: account.email,
        newPhotoUrl:  account.photoUrl ?? '',
      );

      Get.offAllNamed(AppRoutes.home);

    } on GoogleSignInException catch (e) {
      errorMessage.value = _mapGoogleSignInError(e);
    } catch (e) {
      errorMessage.value = 'Đăng nhập thất bại. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Đăng nhập thất bại. Vui lòng thử lại.';
    }
  }
  Future<void> _initializeGoogleSignIn() async {
    if (_googleSignInInitialized) return;

    await _googleSignIn.initialize(
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
    _googleSignInInitialized = true;
  }

  String _mapGoogleSignInError(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return 'Bạn đã huỷ đăng nhập Google.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Đăng nhập thất bại: chưa cấu hình đúng OAuth/SHA-1 trên Google Cloud.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Đăng nhập thất bại: cấu hình Google Play Services hoặc OAuth chưa đúng.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Không mở được màn hình đăng nhập Google trên thiết bị này.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Tài khoản Google không khớp với phiên đăng nhập hiện tại.';
      case GoogleSignInExceptionCode.unknownError:
        return 'Đăng nhập Google thất bại. Kiểm tra SHA-1, package name và Google Cloud OAuth.';
    }
  }
}
