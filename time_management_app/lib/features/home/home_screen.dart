import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../calendar/calendar_screen.dart';
import '../statistics/statistics_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/task_controller.dart';
import '../tasks/widgets/add_task_sheet.dart';
import '../pomodoro/pomodoro_controller.dart';
import '../pomodoro/widgets/focus_picker_sheet.dart';
import '../../services/auth_service.dart';
import '../../shared/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    Get.put(TaskController());
    Get.put(PomodoroController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Obx(() => Text(
          _getTitle(controller.currentIndex.value),
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        )),
        actions: [
          // Avatar người dùng
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.changePage(4),
              child: Obx(() {
                final photo = AuthService.to.photoUrl.value;
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
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

      // ── Body: chỉ build tab đang hiển thị (tránh rebuild ngầm khi gõ phím) ──
      body: Obx(() => _buildTab(controller.currentIndex.value)),

      // ── FAB: Pomodoro → Focus | các tab khác → thêm task | Hồ sơ → ẩn ─────
      floatingActionButton: Obx(() {
        final index = controller.currentIndex.value;
        if (index == 4) return const SizedBox.shrink();
        if (index == 1) {
          return FloatingActionButton(
            onPressed: () => showFocusPickerSheet(context),
            backgroundColor: AppColors.primary,
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: Colors.white,
              size: 28,
            ),
          );
        }
        return FloatingActionButton(
          onPressed: () => showAddTaskSheet(context, Get.find<TaskController>()),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        );
      }),

      // ── Bottom Navigation Bar ───────────────────────────────────────────────
      bottomNavigationBar: Obx(() => _buildBottomNav(controller)),
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const PomodoroScreen();
      case 2:
        return const CalendarScreen();
      case 3:
        return const StatisticsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Tổng quan';
      case 1: return 'Pomodoro';
      case 2: return 'Lịch';
      case 3: return 'Thống kê';
      case 4: return 'Hồ sơ';
      default: return 'TimeWise';
    }
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────
  Widget _buildBottomNav(HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.10),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.tertiary,
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
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Lịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}