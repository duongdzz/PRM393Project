import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class LoginController extends GetxController {
  // ── State ────────────────────────────────────────────────────────────────────
  final isLoading    = false.obs;
  final errorMessage = ''.obs;

  // ── Google Sign-In instance ──────────────────────────────────────────────────
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ── Đăng nhập Google ─────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value    = true;
      errorMessage.value = '';

      // Bước 1: Mở popup chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Người dùng bấm huỷ
        isLoading.value = false;
        return;
      }

      // Bước 2: Lấy token từ Google
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Không lấy được token từ Google');
      }

      // Bước 3: Gửi idToken lên API ASP.NET để verify
      final response = await ApiService.to.post(
        '/api/auth/google-login',
        body: {'idToken': idToken},
      );

      // Bước 4: Lưu session
      await AuthService.to.saveSession(
        newToken:     response['token'],
        newUserId:    response['userId'].toString(),
        newUserName:  response['fullName'] ?? googleUser.displayName ?? '',
        newUserEmail: response['email']    ?? googleUser.email,
        newPhotoUrl:  response['photoUrl'] ?? googleUser.photoUrl ?? '',
      );

      // Bước 5: Chuyển sang màn hình chính
      Get.offAllNamed(AppRoutes.home);

    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Đăng nhập thất bại. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }
}