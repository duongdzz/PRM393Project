import '../models/task_model.dart';

class TaskMapper {
  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    final parsed = DateTime.parse(value.toString());
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static TaskModel fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'].toString(),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: TaskStatus.values[json['status'] as int? ?? 0],
        priority: TaskPriority.values[json['priority'] as int? ?? 1],
        recurrence: RecurrenceType.values[json['recurrence'] as int? ?? 1],
        deadline: _parseDate(json['deadline']),
        startDate: _parseDate(json['startDate']),
        weekDays: (json['weekDays'] as List<dynamic>? ?? [])
            .map((e) => e as int)
            .toList(),
        completedDates: (json['completedDates'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toSet(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        subTasks: (json['subTasks'] as List<dynamic>? ?? [])
            .map((e) => SubTask(
                  id: e['id'] as String,
                  title: e['title'] as String? ?? '',
                  isDone: e['isDone'] as bool? ?? false,
                ))
            .toList(),
      );

  static Map<String, dynamic> toCreateJson(TaskModel task) => {
        'title': task.title,
        'description': task.description,
        'status': task.status.index,
        'priority': task.priority.index,
        'recurrence': task.recurrence.index,
        if (task.deadline != null) 'deadline': dateKey(task.deadline!),
        if (task.startDate != null) 'startDate': dateKey(task.startDate!),
        'weekDays': task.weekDays,
        'subTasks': task.subTasks
            .map((s) => {'title': s.title, 'isDone': s.isDone})
            .toList(),
      };
}
