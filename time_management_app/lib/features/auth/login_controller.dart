import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
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
        await _signInViaApiDev();
        Get.offAllNamed(AppRoutes.home);
        return;
      }

      await _initializeGoogleSignIn();
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final GoogleSignInAuthentication auth = account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        errorMessage.value =
            'Không lấy được idToken Google. Kiểm tra Web OAuth client ID trên Google Cloud.';
        return;
      }

      await _signInViaGoogleToken(idToken);
      Get.offAllNamed(AppRoutes.home);

    } on GoogleSignInException catch (e) {
      errorMessage.value = _mapGoogleSignInError(e);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Đăng nhập thất bại. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _signInViaGoogleToken(String idToken) async {
    final data = await ApiService.to.post(
      '/api/auth/google',
      body: {'idToken': idToken},
    );
    await _saveAuthResponse(data as Map<String, dynamic>);
  }

  /// Web chưa có Google Sign-In widget — dùng dev endpoint khi API chạy Development.
  Future<void> _signInViaApiDev() async {
    final data = await ApiService.to.post('/api/auth/dev');
    await _saveAuthResponse(data as Map<String, dynamic>);
  }

  Future<void> _saveAuthResponse(Map<String, dynamic> data) async {
    await AuthService.to.saveSession(
      newToken:     data['token'] as String? ?? '',
      newUserId:    data['userId'] as String? ?? '',
      newUserName:  data['displayName'] as String? ?? '',
      newUserEmail: data['email'] as String? ?? '',
      newPhotoUrl:  data['photoUrl'] as String? ?? '',
    );
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
