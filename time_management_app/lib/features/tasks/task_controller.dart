import 'package:get/get.dart';

enum TaskStatus   { todo, inProgress, done, cancelled }
enum TaskPriority { low, medium, high, urgent }

/// Định dạng số phút thành chuỗi gọn: 90 -> "1h30p", 45 -> "45p", 120 -> "2h".
String formatDuration(int minutes) {
  if (minutes <= 0) return '0p';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}p';
  if (m == 0) return '${h}h';
  return '${h}h${m}p';
}

class TaskModel {
  final String id;
  String title;
  String description;
  TaskStatus   status;
  TaskPriority priority;
  int?     estimatedMinutes;
  DateTime? deadline;
  DateTime  createdAt;
  DateTime  updatedAt;
  List<SubTask> subTasks;

  TaskModel({
    required this.id,
    required this.title,
    this.description  = '',
    this.status       = TaskStatus.todo,
    this.priority     = TaskPriority.medium,
    this.estimatedMinutes,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.subTasks     = const [],
  });

  bool get isOverdue =>
      deadline != null &&
          deadline!.isBefore(DateTime.now()) &&
          status != TaskStatus.done &&
          status != TaskStatus.cancelled;

  // Business Rule: không cho done nếu còn sub-task chưa xong
  bool get canMarkDone => subTasks.every((s) => s.isDone);
}

class SubTask {
  final String id;
  String title;
  bool isDone;

  SubTask({required this.id, required this.title, this.isDone = false});
}

// ─────────────────────────────────────────────────────────────────────────────

class TaskController extends GetxController {
  final tasks = <TaskModel>[].obs;

  List<TaskModel> get overdueTasks =>
      tasks.where((t) => t.isOverdue).toList();

  void addTask(TaskModel task) => tasks.add(task);

  // Business Rule: không cho done nếu còn sub-task chưa xong.
  // Trả về null nếu thành công, hoặc thông báo lỗi.
  String? tryMarkDone(String taskId) {
    final task = tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return 'Task không tồn tại';
    if (!task.canMarkDone) {
      return 'Còn ${task.subTasks.where((s) => !s.isDone).length} công việc con chưa hoàn thành';
    }
    task.status = TaskStatus.done;
    task.updatedAt = DateTime.now();
    tasks.refresh();
    return null;
  }
}