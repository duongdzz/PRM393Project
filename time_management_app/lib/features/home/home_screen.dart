import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../tasks/task_list_screen.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        title: Obx(() => Text(
          _getTitle(controller.currentIndex.value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        )),
        actions: [
          // Avatar người dùng
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.profile),
              child: Obx(() {
                final photo = AuthService.to.photoUrl.value;
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF6C63FF),
                  backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                  child: photo.isEmpty
                      ? Text(
                    AuthService.to.userName.value.isNotEmpty
                        ? AuthService.to.userName.value[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                      : null,
                );
              }),
            ),
          ),
        ],
      ),

      // ── Drawer ──────────────────────────────────────────────────────────────
      drawer: _buildDrawer(),

      // ── Body: 3 tab content ─────────────────────────────────────────────────
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          DashboardScreen(),
          PomodoroScreen(),
          TaskListScreen(),
        ],
      ),

      // ── Bottom Navigation Bar ───────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(controller),
    ));
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Tổng quan';
      case 1: return 'Pomodoro';
      case 2: return 'Công việc';
      default: return 'TimeFlow';
    }
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────
  Widget _buildBottomNav(HomeController controller) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.white30,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer_rounded),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            activeIcon: Icon(Icons.task_alt_rounded),
            label: 'Công việc',
          ),
        ],
      ),
    ));
  }

  // ── Drawer ───────────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A2E),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF16213E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final photo = AuthService.to.photoUrl.value;
                    return CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF6C63FF),
                      backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                      child: photo.isEmpty
                          ? Text(
                        AuthService.to.userName.value.isNotEmpty
                            ? AuthService.to.userName.value[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    );
                  }),
                  const SizedBox(height: 12),
                  Obx(() => Text(
                    AuthService.to.userName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  Obx(() => Text(
                    AuthService.to.userEmail.value,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Menu items
            _drawerItem(Icons.person_outline, 'Hồ sơ', () {
              Get.back();
              Get.toNamed(AppRoutes.profile);
            }),
            _drawerItem(Icons.calendar_month_outlined, 'Lập lịch', () {
              Get.back();
              Get.toNamed(AppRoutes.schedule);
            }),
            _drawerItem(Icons.bar_chart_rounded, 'Báo cáo', () {
              Get.back();
              Get.toNamed(AppRoutes.report);
            }),
            _drawerItem(Icons.settings_outlined, 'Cài đặt', () {
              Get.back();
            }),

            const Spacer(),

            // Đăng xuất
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () async {
                  await AuthService.to.clearSession();
                  Get.offAllNamed(AppRoutes.login);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white60, size: 22),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 15),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.05),
    );
  }
}