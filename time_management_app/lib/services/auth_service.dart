import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthService — singleton quản lý session người dùng.

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  // Keys lưu trong SharedPreferences
  static const _keyToken     = 'auth_token';
  static const _keyUserId    = 'user_id';
  static const _keyUserName  = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyPhotoUrl  = 'photo_url';

  // Observable user info (dùng trong toàn app qua AuthService.to.xxx)
  final token     = ''.obs;
  final userId    = ''.obs;
  final userName  = ''.obs;
  final userEmail = ''.obs;
  final photoUrl  = ''.obs;

  late SharedPreferences _prefs;

  // ── Khởi tạo service (gọi trong main.dart trước runApp) ──────────────────────
  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load dữ liệu đã lưu vào observable
    token.value     = _prefs.getString(_keyToken)     ?? '';
    userId.value    = _prefs.getString(_keyUserId)    ?? '';
    userName.value  = _prefs.getString(_keyUserName)  ?? '';
    userEmail.value = _prefs.getString(_keyUserEmail) ?? '';
    photoUrl.value  = _prefs.getString(_keyPhotoUrl)  ?? '';
    return this;
  }

  // ── Kiểm tra session còn hợp lệ không ────────────────────────────────────────
  /// Trả về true nếu có token hợp lệ.
  /// Mở rộng sau: gọi API /auth/verify-token để validate với server.
  Future<bool> checkSession() async {
    if (token.value.isEmpty) return false;

    // TODO: Gọi REST API kiểm tra token còn hạn không
    // try {
    //   final response = await ApiService.to.get('/auth/verify-token');
    //   return response.statusCode == 200;
    // } catch (_) {
    //   return false;
    // }

    return true; // Tạm thời tin tưởng token local
  }

  // ── Lưu session sau đăng nhập thành công ─────────────────────────────────────
  Future<void> saveSession({
    required String newToken,
    required String newUserId,
    required String newUserName,
    required String newUserEmail,
    String newPhotoUrl = '',
  }) async {
    token.value     = newToken;
    userId.value    = newUserId;
    userName.value  = newUserName;
    userEmail.value = newUserEmail;
    photoUrl.value  = newPhotoUrl;

    await _prefs.setString(_keyToken,     newToken);
    await _prefs.setString(_keyUserId,    newUserId);
    await _prefs.setString(_keyUserName,  newUserName);
    await _prefs.setString(_keyUserEmail, newUserEmail);
    await _prefs.setString(_keyPhotoUrl,  newPhotoUrl);
  }

  // ── Xoá session khi đăng xuất ─────────────────────────────────────────────────
  Future<void> clearSession() async {
    token.value     = '';
    userId.value    = '';
    userName.value  = '';
    userEmail.value = '';
    photoUrl.value  = '';

    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyPhotoUrl);
  }
}