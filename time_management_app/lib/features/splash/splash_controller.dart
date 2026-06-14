import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  // ── Animations ──────────────────────────────────────────────────────────────
  late AnimationController _animController;
  late Animation<double> logoAnimation;
  late Animation<double> textAnimation;

  // ── Observable state ────────────────────────────────────────────────────────
  final statusText = 'Đang khởi động...'.obs;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initAnimations();
    _startSequence();
  }

  @override
  void onClose() {
    _animController.dispose();
    super.onClose();
  }

  // ── Private methods ───────────────────────────────────────────────────────────

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Logo scale: 0.4 → 1.0 trong 0–60% thời gian
    logoAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Text fade-in: 0 → 1 trong 40–100% thời gian
    textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  Future<void> _startSequence() async {
    // Bước 1: Chạy animation (1.8s)
    await Future.delayed(const Duration(milliseconds: 1800));

    // Bước 2: Kiểm tra token / session
    statusText.value = 'Đang kiểm tra phiên đăng nhập...';
    await Future.delayed(const Duration(milliseconds: 400));

    final bool isLoggedIn = await AuthService.to.checkSession();

    // Bước 3: Điều hướng
    if (isLoggedIn) {
      statusText.value = 'Chào mừng trở lại!';
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(AppRoutes.home);
    } else {
      statusText.value = 'Vui lòng đăng nhập';
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
