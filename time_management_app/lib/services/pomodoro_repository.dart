import '../features/pomodoro/pomodoro_controller.dart';
import 'api_service.dart';
import 'auth_service.dart';

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

class PomodoroRepository {
  PomodoroRepository._();
  static PomodoroRepository get to => PomodoroRepository._();

  Future<List<PomodoroSession>> fetchToday() async {
    if (!AuthService.to.useApi) return [];

    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final data =
        await ApiService.to.get('/api/pomodoro/sessions', params: {'date': date});
    return (data as List<dynamic>)
        .map((e) => PomodoroMapper.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create(PomodoroSession session, {String? taskTitle}) async {
    if (!AuthService.to.useApi) return;

    await ApiService.to.post(
      '/api/pomodoro/sessions',
      body: PomodoroMapper.toCreateJson(session, taskTitle: taskTitle),
    );
  }
}
