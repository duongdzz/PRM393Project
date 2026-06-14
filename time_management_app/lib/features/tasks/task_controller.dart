import 'package:get/get.dart';

enum TaskStatus   { todo, inProgress, done, cancelled }
enum TaskPriority { low, medium, high, urgent }

/// Kiểu lặp lại — trọng tâm app là công việc lặp đi lặp lại.
enum RecurrenceType { once, daily, weekdays, weekly, monthly }

extension RecurrenceTypeX on RecurrenceType {
  String get label {
    switch (this) {
      case RecurrenceType.once:      return 'Một lần';
      case RecurrenceType.daily:     return 'Hàng ngày';
      case RecurrenceType.weekdays:  return 'T2–T6';
      case RecurrenceType.weekly:    return 'Hàng tuần';
      case RecurrenceType.monthly:   return 'Hàng tháng';
    }
  }
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
String dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

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
  RecurrenceType recurrence;
  DateTime? deadline;      // chỉ dùng cho việc một lần
  DateTime? startDate;     // ngày bắt đầu lặp
  List<int> weekDays;      // 1=T2 … 7=CN, dùng khi recurrence == weekly
  final Set<String> completedDates;
  DateTime  createdAt;
  DateTime  updatedAt;
  List<SubTask> subTasks;

  TaskModel({
    required this.id,
    required this.title,
    this.description     = '',
    this.status          = TaskStatus.todo,
    this.priority        = TaskPriority.medium,
    this.recurrence      = RecurrenceType.daily,
    this.deadline,
    this.startDate,
    this.weekDays        = const [],
    Set<String>? completedDates,
    required this.createdAt,
    required this.updatedAt,
    this.subTasks         = const [],
  }) : completedDates = completedDates ?? {};

  bool get isRecurring => recurrence != RecurrenceType.once;

  bool get isOverdue =>
      recurrence == RecurrenceType.once &&
      deadline != null &&
      deadline!.isBefore(DateTime.now()) &&
      status != TaskStatus.done &&
      status != TaskStatus.cancelled;

  bool get canMarkDone => subTasks.every((s) => s.isDone);
}

class SubTask {
  final String id;
  String title;
  bool isDone;

  SubTask({required this.id, required this.title, this.isDone = false});
}

class TaskController extends GetxController {
  final tasks = <TaskModel>[].obs;

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
    return task.completedDates.contains(dateKey(day));
  }

  List<TaskModel> tasksOn(DateTime day) {
    return tasks.where((t) => occursOn(t, day)).toList()
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  void addTask(TaskModel task) => tasks.add(task);

  String? tryMarkDone(String taskId, {DateTime? onDate}) {
    final task = tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return 'Task không tồn tại';
    if (!task.canMarkDone) {
      return 'Còn ${task.subTasks.where((s) => !s.isDone).length} công việc con chưa hoàn thành';
    }

    final day = dateOnly(onDate ?? DateTime.now());

    if (task.recurrence == RecurrenceType.once) {
      task.status = TaskStatus.done;
    } else {
      if (!occursOn(task, day)) return 'Công việc không có trong ngày này';
      task.completedDates.add(dateKey(day));
    }
    task.updatedAt = DateTime.now();
    tasks.refresh();
    return null;
  }
}
