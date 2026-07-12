import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';
import '../../data/task_repository.dart';
import '../../data/local_task_store.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../shared/theme/app_theme.dart';

class TaskController extends GetxController {
  final tasks = <TaskModel>[].obs;
  final markingTaskIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    if (!AuthService.to.useApi) {
      tasks.assignAll(await LocalTaskStore.to.load());
      return;
    }

    try {
      tasks.assignAll(await TaskRepository.to.fetchAll());
    } on ApiException catch (e) {
      Get.snackbar('Lỗi', e.message,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
    }
  }

  Future<void> _persistGuestTasks() async {
    if (!AuthService.to.useApi) {
      await LocalTaskStore.to.save(tasks);
    }
  }

  List<TaskModel> get overdueTasks =>
      tasks.where((t) => t.isOverdue).toList();

  int get recurringCount =>
      tasks.where((t) => t.isRecurring && t.status != TaskStatus.cancelled).length;

  bool occursOn(TaskModel task, DateTime day) {
    if (task.status == TaskStatus.cancelled) return false;
    final d = dateOnly(day);

    if (task.recurrence == RecurrenceType.once) {
      if (task.deadline == null) return false;
      return isSameDay(task.deadline!, d);
    }

    final start = task.startDate;
    if (start == null) return false;
    if (d.isBefore(dateOnly(start))) return false;

    switch (task.recurrence) {
      case RecurrenceType.once:
        return false;
      case RecurrenceType.daily:
        return true;
      case RecurrenceType.weekdays:
        return d.weekday >= 1 && d.weekday <= 5;
      case RecurrenceType.weekly:
        if (task.weekDays.isEmpty) return d.weekday == start.weekday;
        return task.weekDays.contains(d.weekday);
      case RecurrenceType.monthly:
        return d.day == start.day;
    }
  }

  bool isDoneOn(TaskModel task, DateTime day) {
    if (task.recurrence == RecurrenceType.once) {
      return task.status == TaskStatus.done;
    }
    final target = dateKey(day);
    return task.completedDates.any((d) => normalizeDateKey(d) == target);
  }

  List<TaskModel> tasksOn(DateTime day) {
    return tasks.where((t) => occursOn(t, day)).toList()
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  Future<String?> addTask(TaskModel task) async {
    if (!AuthService.to.useApi) {
      tasks.add(task);
      await _persistGuestTasks();
      return null;
    }

    try {
      final created = await TaskRepository.to.create(task);
      tasks.add(created);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  bool isMarkingDone(String taskId) => markingTaskIds.contains(taskId);

  void _setMarking(String taskId, bool marking) {
    if (marking) {
      if (!markingTaskIds.contains(taskId)) markingTaskIds.add(taskId);
    } else {
      markingTaskIds.remove(taskId);
    }
  }

  void _applyMarkDoneLocally(TaskModel task, DateTime day) {
    if (task.recurrence == RecurrenceType.once) {
      task.status = TaskStatus.done;
    } else {
      task.completedDates.add(dateKey(day));
    }
    task.updatedAt = DateTime.now();
  }

  void _revertMarkDoneLocally(
    TaskModel task,
    DateTime day, {
    required TaskStatus previousStatus,
    required Set<String> previousCompletedDates,
  }) {
    task.status = previousStatus;
    task.completedDates
      ..clear()
      ..addAll(previousCompletedDates);
    task.updatedAt = DateTime.now();
  }

  Future<String?> tryMarkDone(String taskId, {DateTime? onDate}) async {
    if (markingTaskIds.contains(taskId)) return null;

    final task = tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return 'Task không tồn tại';
    if (!task.canMarkDone) {
      return 'Còn ${task.subTasks.where((s) => !s.isDone).length} công việc con chưa hoàn thành';
    }

    final day = dateOnly(onDate ?? DateTime.now());

    if (task.recurrence == RecurrenceType.once) {
      if (task.status == TaskStatus.done) return null;
    } else {
      if (!occursOn(task, day)) return 'Công việc không có trong ngày này';
      if (task.completedDates.any((d) => normalizeDateKey(d) == dateKey(day))) {
        return null;
      }
    }

    final previousStatus = task.status;
    final previousCompletedDates = Set<String>.from(task.completedDates);

    _setMarking(taskId, true);
    _applyMarkDoneLocally(task, day);
    tasks.refresh();

    if (!AuthService.to.useApi) {
      _setMarking(taskId, false);
      _persistGuestTasks();
      return null;
    }

    try {
      final updated = await TaskRepository.to.complete(taskId, day);
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index >= 0) tasks[index] = updated;
      tasks.refresh();
      return null;
    } on ApiException catch (e) {
      _revertMarkDoneLocally(
        task,
        day,
        previousStatus: previousStatus,
        previousCompletedDates: previousCompletedDates,
      );
      tasks.refresh();
      return e.message;
    } catch (_) {
      _revertMarkDoneLocally(
        task,
        day,
        previousStatus: previousStatus,
        previousCompletedDates: previousCompletedDates,
      );
      tasks.refresh();
      return 'Không thể hoàn thành công việc';
    } finally {
      _setMarking(taskId, false);
    }
  }

  Future<void> markDoneWithFeedback(String taskId, {DateTime? onDate}) async {
    final error = await tryMarkDone(taskId, onDate: onDate);
    if (error != null) {
      Get.snackbar(
        'Không thể hoàn thành',
        error,
        backgroundColor: AppColors.surface,
        colorText: AppColors.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<String?> deleteTask(String taskId) async {
    if (!AuthService.to.useApi) {
      tasks.removeWhere((t) => t.id == taskId);
      await _persistGuestTasks();
      return null;
    }

    try {
      await TaskRepository.to.delete(taskId);
      tasks.removeWhere((t) => t.id == taskId);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> deleteWithFeedback(String taskId, String taskTitle) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xóa công việc'),
        content: Text('Bạn có chắc muốn xóa "$taskTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final error = await deleteTask(taskId);
    if (error != null) {
      Get.snackbar(
        'Không thể xóa',
        error,
        backgroundColor: AppColors.surface,
        colorText: AppColors.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    Get.snackbar(
      'Đã xóa',
      taskTitle,
      backgroundColor: AppColors.surface,
      colorText: AppColors.onSurface,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
