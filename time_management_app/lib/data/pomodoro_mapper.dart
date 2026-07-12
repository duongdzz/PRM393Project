import '../models/pomodoro_model.dart';

class PomodoroMapper {
  static PomodoroSession fromJson(Map<String, dynamic> json) => PomodoroSession(
        type: PomodoroType.values[json['sessionType'] as int? ?? 0],
        startedAt: DateTime.parse(json['startedAt'] as String).toLocal(),
        completed: json['completed'] as bool? ?? false,
      )
        ..endedAt = json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String).toLocal()
            : null;

  static Map<String, dynamic> toCreateJson(
    PomodoroSession session, {
    String? taskTitle,
  }) =>
      {
        'taskTitle': taskTitle?.isNotEmpty == true ? taskTitle : null,
        'sessionType': session.type.index,
        'startedAt': session.startedAt.toUtc().toIso8601String(),
        if (session.endedAt != null)
          'endedAt': session.endedAt!.toUtc().toIso8601String(),
        'completed': session.completed,
      };
}
