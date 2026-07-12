import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';
import '../tasks/task_controller.dart';
import '../pomodoro/pomodoro_controller.dart';
import '../../shared/theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskC = Get.find<TaskController>();
    final pomoC = Get.find<PomodoroController>();

    return Container(
      color: AppColors.background,
      child: Obx(() {
        final today = dateOnly(DateTime.now());
        final todayTasks = taskC.tasksOn(today);
        final doneToday = todayTasks.where((t) => taskC.isDoneOn(t, today)).length;
        final todoToday = todayTasks.length - doneToday;
        final recurring = taskC.recurringCount;
        final overdue = taskC.overdueTasks.length;
        final completionRate = todayTasks.isEmpty ? 0.0 : doneToday / todayTasks.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompletionCard(doneToday, todayTasks.length, completionRate),
              const SizedBox(height: 20),

              const Text('Hôm nay',
                  style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _statCard('$todoToday', 'Cần làm', Icons.radio_button_unchecked_rounded, AppColors.tertiary)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('$doneToday', 'Đã xong', Icons.check_circle_rounded, AppColors.success)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _statCard('$recurring', 'Việc lặp lại', Icons.repeat_rounded, AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('$overdue', 'Quá hạn', Icons.warning_amber_rounded, AppColors.error)),
                ],
              ),

              const SizedBox(height: 24),

              const Text('Phân bố theo mức ưu tiên',
                  style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildPriorityChart(taskC.tasks),

              const SizedBox(height: 24),

              const Text('Pomodoro hôm nay',
                  style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _statCard(
                    '${pomoC.todayCompletedSessions}', 'Phiên tập trung',
                    Icons.timer_rounded, AppColors.error)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard(
                    '${pomoC.todayFocusMinutes}p', 'Thời gian focus',
                    Icons.access_time_filled_rounded, AppColors.success)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Completion card ─────────────────────────────────────────────────────────
  Widget _buildCompletionCard(int done, int total, double rate) {
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
      child: Row(
        children: [
          SizedBox(
            width: 64, height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64, height: 64,
                  child: CircularProgressIndicator(
                    value: rate,
                    strokeWidth: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text('${(rate * 100).round()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tỷ lệ hoàn thành hôm nay',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text('$done / $total lần lặp',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  rate >= 0.8
                      ? 'Tuyệt vời! 🎉'
                      : rate >= 0.5
                          ? 'Đang tiến bộ tốt 💪'
                          : 'Cố lên nhé! 🚀',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
                Text(label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.tertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Priority distribution bar chart ──────────────────────────────────────────
  Widget _buildPriorityChart(List<TaskModel> tasks) {
    final active = tasks.where((t) => t.status != TaskStatus.cancelled).toList();
    final data = <TaskPriority, int>{
      TaskPriority.urgent: active.where((t) => t.priority == TaskPriority.urgent).length,
      TaskPriority.high:   active.where((t) => t.priority == TaskPriority.high).length,
      TaskPriority.medium: active.where((t) => t.priority == TaskPriority.medium).length,
      TaskPriority.low:    active.where((t) => t.priority == TaskPriority.low).length,
    };
    final maxVal = data.values.isEmpty ? 0 : data.values.reduce((a, b) => a > b ? a : b);

    final labels = {
      TaskPriority.urgent: 'Khẩn cấp',
      TaskPriority.high:   'Cao',
      TaskPriority.medium: 'Trung bình',
      TaskPriority.low:    'Thấp',
    };
    final colors = {
      TaskPriority.urgent: AppColors.error,
      TaskPriority.high:   AppColors.warning,
      TaskPriority.medium: AppColors.primary,
      TaskPriority.low:    AppColors.tertiary,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: data.entries.map((e) {
          final fraction = maxVal == 0 ? 0.0 : e.value / maxVal;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(labels[e.key]!,
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LayoutBuilder(
                      builder: (_, constraints) => Stack(
                        children: [
                          Container(height: 14, color: AppColors.inputFill),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 14,
                            width: constraints.maxWidth * fraction,
                            color: colors[e.key],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 24,
                  child: Text('${e.value}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppColors.onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
