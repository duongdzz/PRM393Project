enum PomodoroStatus { idle, running, paused, finished }
enum PomodoroType   { work, shortBreak, longBreak }

class PomodoroSession {
  final PomodoroType type;
  final DateTime startedAt;
  DateTime? endedAt;
  bool completed;

  PomodoroSession({
    required this.type,
    required this.startedAt,
    this.completed = false,
  });
}
