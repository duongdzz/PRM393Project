import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../shared/theme/app_theme.dart';
import '../tasks/task_controller.dart';
import '../pomodoro/pomodoro_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const int _dailyGoalMinutes = 480;

  @override
  Widget build(BuildContext context) {
    final taskC = Get.put(TaskController());
    final pomoC = Get.put(PomodoroController());

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

            final focusMin = pomoC.todayFocusMinutes;
            final sessions = pomoC.todayCompletedSessions;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressCard(focusMin),
                const SizedBox(height: 20),

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
                  ...todayAll.map((t) => _TodayTaskTile(
                        task: t,
                        controller: taskC,
                        occurrenceDate: now,
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

  Widget _buildProgressCard(int focusMin) {
    final progress = (focusMin / _dailyGoalMinutes).clamp(0.0, 1.0);
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
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mục tiêu hôm nay', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('$focusMin / $_dailyGoalMinutes phút',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
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
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.tertiary, fontSize: 11), textAlign: TextAlign.center),
        ],
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

// ── Today task tile ─────────────────────────────────────────────────────────
class _TodayTaskTile extends StatelessWidget {
  final TaskModel task;
  final TaskController controller;
  final DateTime occurrenceDate;
  const _TodayTaskTile({
    required this.task,
    required this.controller,
    required this.occurrenceDate,
  });

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:    return AppColors.tertiary;
      case TaskPriority.medium: return AppColors.primary;
      case TaskPriority.high:   return AppColors.warning;
      case TaskPriority.urgent: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = controller.isDoneOn(task, occurrenceDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone ? AppColors.success.withOpacity(0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: isDone ? AppColors.success : _priorityColor(task.priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: isDone ? AppColors.tertiary : AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isDone ? Icons.check_circle_rounded : Icons.repeat_rounded,
                      size: 12,
                      color: isDone ? AppColors.success : AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDone ? 'Đã hoàn thành' : task.recurrence.label,
                      style: TextStyle(
                        color: isDone ? AppColors.success : AppColors.tertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isDone)
            GestureDetector(
              onTap: () {
                final error = controller.tryMarkDone(task.id, onDate: occurrenceDate);
                if (error != null) {
                  Get.snackbar('Không thể hoàn thành', error,
                      backgroundColor: AppColors.surface,
                      colorText: AppColors.onSurface,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12);
                }
              },
              child: const Icon(Icons.radio_button_unchecked_rounded,
                  color: AppColors.tertiary, size: 22),
            )
          else
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
        ],
      ),
    );
  }
}
