import '../models/pomodoro_model.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'pomodoro_mapper.dart';

class PomodoroRepository {
  PomodoroRepository._();
  static PomodoroRepository get to => PomodoroRepository._();

  Future<List<PomodoroSession>> fetchToday() async {
    if (!AuthService.to.useApi) return [];

    final date = dateKey(DateTime.now());
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
