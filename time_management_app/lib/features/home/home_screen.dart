import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

/// Màn hình tạm sau đăng nhập — thay bằng UI thật khi làm xong feature.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.to;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('TimeWise'),
        actions: [
          TextButton(
            onPressed: () async {
              await auth.clearSession();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF6C63FF), size: 64),
              const SizedBox(height: 16),
              Text(
                'Xin chào, ${auth.userName.value.isNotEmpty ? auth.userName.value : "bạn"}!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                auth.userEmail.value,
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đăng nhập Google thành công.\nMàn hình chính sẽ được bổ sung sau.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
