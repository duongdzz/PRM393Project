import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/task_tile.dart';
import '../../models/task_model.dart';
import '../home/home_controller.dart';
import '../tasks/task_controller.dart';
import '../pomodoro/pomodoro_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskC = Get.find<TaskController>();
    final pomoC = Get.find<PomodoroController>();
    final homeC = Get.find<HomeController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Obx(() => Text(
            'Chào, ${AuthService.to.userName.value.isNotEmpty ? AuthService.to.userName.value : 'bạn'} 👋',
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          )),
          const SizedBox(height: 4),
          Text(
            _getDateString(),
            style: const TextStyle(color: AppColors.tertiary, fontSize: 13),
          ),

          const SizedBox(height: 24),

          // Nội dung phản ứng theo dữ liệu task + pomodoro
          Obx(() {
            final now = dateOnly(DateTime.now());
            final todayAll = taskC.tasksOn(now);

            final remaining = todayAll
                .where((t) => !taskC.isDoneOn(t, now))
                .toList();
            final doneCount = todayAll
                .where((t) => taskC.isDoneOn(t, now))
                .length;

            final focusMin = pomoC.todayFocusMinutes.value;
            final sessions = pomoC.todayCompletedSessions.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressCard(context, homeC, pomoC),
                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(child: _buildStatCard('${remaining.length}', 'Việc hôm nay', Icons.task_alt_rounded, AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('$sessions', 'Pomodoro', Icons.timer_rounded, AppColors.error)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(_focusText(focusMin), 'Tập trung', Icons.access_time_rounded, AppColors.success)),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Text(
                      'Việc lặp lại hôm nay',
                      style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (doneCount > 0)
                      Text(
                        'Đã xong $doneCount',
                        style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (todayAll.isEmpty)
                  _buildEmptyState('Chưa có công việc lặp lại hôm nay', Icons.repeat_rounded)
                else
                  ...todayAll.map((t) => TaskTile(
                        task: t,
                        controller: taskC,
                        occurrenceDate: now,
                        subtitle: taskC.isDoneOn(t, now)
                            ? 'Đã hoàn thành'
                            : t.recurrence.label,
                      )),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _focusText(int minutes) {
    if (minutes < 60) return '${minutes}p';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m}p';
  }

  String _getDateString() {
    final now = DateTime.now();
    const days = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    return '${days[now.weekday % 7]}, ${now.day}/${now.month}/${now.year}';
  }

  Widget _buildProgressCard(
    BuildContext context,
    HomeController homeC,
    PomodoroController pomoC,
  ) {
    return Obx(() {
      final goal = homeC.dailyGoalMinutes.value;
      final focusMin = pomoC.todayFocusMinutes.value;
      final progress = goal > 0 ? (focusMin / goal).clamp(0.0, 1.0) : 0.0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.skyGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mục tiêu hôm nay',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                Text(
                  '$focusMin / $goal phút',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showDailyGoalDialog(context, homeC),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha:0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              focusMin == 0
                  ? 'Bắt đầu ngày mới thôi! 💪'
                  : progress >= 1.0
                      ? 'Hoàn thành mục tiêu hôm nay! 🎉'
                      : 'Đang tập trung tốt, tiếp tục nhé! 🔥',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showDailyGoalDialog(
    BuildContext context,
    HomeController homeC,
  ) async {
    final controller = TextEditingController(
      text: '${homeC.dailyGoalMinutes.value}',
    );

    final saved = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Đặt mục tiêu hôm nay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập số phút tập trung bạn muốn đạt mỗi ngày.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Mục tiêu (phút)',
                suffixText: 'phút',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gợi ý: 60, 120, 240, 480 phút',
              style: TextStyle(color: AppColors.tertiary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final minutes = int.tryParse(controller.text.trim());
    if (minutes == null) {
      Get.snackbar(
        'Không hợp lệ',
        'Vui lòng nhập số phút (1–1440).',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final ok = await homeC.setDailyGoal(minutes);
    if (!ok) {
      Get.snackbar(
        'Không hợp lệ',
        'Mục tiêu phải từ 1 đến 1440 phút (24 giờ).',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return SizedBox(
      height: 110,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.onSurface, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 26,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.tertiary, fontSize: 11, height: 1.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.tertiary, size: 36),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: AppColors.tertiary, fontSize: 13)),
        ],
      ),
    );
  }
}
