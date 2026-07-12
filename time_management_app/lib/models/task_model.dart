import 'package:flutter/material.dart';
import '../shared/theme/app_theme.dart';

enum TaskStatus   { todo, inProgress, done, cancelled }
enum TaskPriority { low, medium, high, urgent }

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

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

Color priorityColor(TaskPriority p) {
  switch (p) {
    case TaskPriority.low:    return AppColors.tertiary;
    case TaskPriority.medium: return AppColors.primary;
    case TaskPriority.high:   return AppColors.warning;
    case TaskPriority.urgent: return AppColors.error;
  }
}

class TaskModel {
  final String id;
  String title;
  String description;
  TaskStatus   status;
  TaskPriority priority;
  RecurrenceType recurrence;
  DateTime? deadline;
  DateTime? startDate;
  List<int> weekDays;
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
