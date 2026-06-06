import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../shared/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              _buildMenuItem(Icons.person_outline, 'Thông tin cá nhân', () {}),
              _buildMenuItem(Icons.notifications_outlined, 'Thông báo', () {}),
              _buildMenuItem(Icons.settings_outlined, 'Cài đặt', () {}),
              _buildMenuItem(Icons.help_outline_rounded, 'Trợ giúp & Hỗ trợ', () {}),

              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header (avatar + name + email) ───────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.skyGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() {
            final photo = AuthService.to.photoUrl.value;
            return CircleAvatar(
              radius: 44,
              backgroundColor: Colors.white,
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty
                  ? Text(
                      AuthService.to.userName.value.isNotEmpty
                          ? AuthService.to.userName.value[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            );
          }),
          const SizedBox(height: 16),
          Obx(() => Text(
                AuthService.to.userName.value.isNotEmpty
                    ? AuthService.to.userName.value
                    : 'Người dùng',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                AuthService.to.userEmail.value,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              )),
        ],
      ),
    );
  }

  // ── Menu item ─────────────────────────────────────────────────────────────────
  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(label, style: const TextStyle(color: AppColors.onSurface, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.tertiary),
        onTap: onTap,
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        await AuthService.to.clearSession();
        Get.offAllNamed(AppRoutes.login);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
