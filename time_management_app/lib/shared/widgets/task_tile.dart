import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';
import '../../features/tasks/task_controller.dart';
import '../../shared/theme/app_theme.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final TaskController controller;
  final DateTime occurrenceDate;
  final String subtitle;
  final Color backgroundColor;

  static String _displayDescription(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  const TaskTile({
    super.key,
    required this.task,
    required this.controller,
    required this.occurrenceDate,
    required this.subtitle,
    this.backgroundColor = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final liveTask =
          controller.tasks.firstWhereOrNull((t) => t.id == task.id) ?? task;
      final isDone = controller.isDoneOn(liveTask, occurrenceDate);
      final isBusy = controller.markingTaskIds.contains(task.id);

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isDone ? AppColors.success : priorityColor(liveTask.priority),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onLongPress: () =>
                    controller.deleteWithFeedback(liveTask.id, liveTask.title),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveTask.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDone ? AppColors.tertiary : AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (liveTask.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _displayDescription(liveTask.description),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDone
                              ? AppColors.tertiary
                              : AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : (liveTask.isRecurring
                                  ? Icons.repeat_rounded
                                  : Icons.calendar_today_outlined),
                          size: 12,
                          color: isDone ? AppColors.success : AppColors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subtitle,
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
            ),
            const SizedBox(width: 8),
            if (!isDone)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isBusy
                    ? null
                    : () => controller.markDoneWithFeedback(
                          task.id,
                          onDate: occurrenceDate,
                        ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: isBusy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.radio_button_unchecked_rounded,
                          color: AppColors.tertiary,
                          size: 22,
                        ),
                ),
              )
            else
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
          ],
        ),
      );
    });
  }
}
