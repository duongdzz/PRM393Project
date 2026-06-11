import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import '../../shared/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background decoration
          _buildBackground(),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // Logo + title
                  _buildHeader(),

                  const Spacer(flex: 3),

                  // Google Sign-In button
                  _buildGoogleButton(controller),

                  const SizedBox(height: 12),
                  _buildGuestButton(controller),

                  const SizedBox(height: 16),

                  // Thông báo lỗi
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? _buildErrorMessage(controller.errorMessage.value)
                      : const SizedBox.shrink()),

                  const Spacer(flex: 2),

                  // Footer
                  _buildFooter(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return CustomPaint(
      painter: _LoginBackgroundPainter(),
      child: const SizedBox.expand(),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: AppColors.skyGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.timer_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Xin chào!',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Đăng nhập để bắt đầu\nquản lý thời gian của bạn',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 48),

        // Feature highlights
        _buildFeatureRow(Icons.timer_outlined, 'Pomodoro thông minh'),
        const SizedBox(height: 12),
        _buildFeatureRow(Icons.task_alt_outlined, 'Quản lý công việc'),
        const SizedBox(height: 12),
        _buildFeatureRow(Icons.bar_chart_rounded, 'Báo cáo năng suất'),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ── Google Button ────────────────────────────────────────────────────────────
  Widget _buildGoogleButton(LoginController controller) {
    return Obx(() => GestureDetector(
      onTap: controller.isLoading.value ? null : controller.signInWithGoogle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: controller.isLoading.value
              ? AppColors.inputFill
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: controller.isLoading.value
              ? []
              : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: controller.isLoading.value
            ? const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google logo SVG-like (dùng text vì không có asset)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(
                Icons.g_mobiledata_rounded,
                size: 28,
                color: Color(0xFF4285F4),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Đăng nhập với Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // ── Guest button ─────────────────────────────────────────────────────────────
  Widget _buildGuestButton(LoginController controller) {
    return Obx(() => TextButton(
      onPressed: controller.isLoading.value ? null : controller.signInAsGuest,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Text(
        'Tiếp tục với tài khoản khách',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ));
  }

  // ── Error message ────────────────────────────────────────────────────────────
  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: Text(
        'Bằng cách đăng nhập, bạn đồng ý với\nChính sách bảo mật của TimeWise',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.tertiary,
          fontSize: 12,
          height: 1.6,
        ),
      ),
    );
  }
}

// ── Background Painter ────────────────────────────────────────────────────────
class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.primary.withOpacity(0.10);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.12), 160, paint);

    paint.color = AppColors.skyLight.withOpacity(0.12);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.75), 130, paint);

    paint.color = AppColors.primary.withOpacity(0.06);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.95), 100, paint);
  }

  @override
  bool shouldRepaint(_LoginBackgroundPainter old) => false;
}