import 'dart:async';
import 'package:get/get.dart';
import '../../shared/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/pomodoro_repository.dart';
import 'package:flutter/material.dart';

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

class PomodoroController extends GetxController {
  // ── Settings (phút) ──────────────────────────────────────────────────────────
  final workMinutes       = 25.obs;
  final shortBreakMinutes = 5.obs;
  final longBreakMinutes  = 15.obs;
  final sessionsUntilLong = 4.obs;   // sau 4 work session → long break

  // ── State ────────────────────────────────────────────────────────────────────
  final status          = PomodoroStatus.idle.obs;
  final currentType     = PomodoroType.work.obs;
  final remainingSeconds = (25 * 60).obs;
  final completedWork   = 0.obs;     // số work session hoàn thành hôm nay
  final currentTask     = ''.obs;    // tên task đang focus

  // ── History ──────────────────────────────────────────────────────────────────
  final sessions = <PomodoroSession>[].obs;

  Timer? _timer;
  PomodoroSession? _currentSession;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  Future<void> loadSessions() async {
    if (!AuthService.to.useApi) return;

    try {
      final list = await PomodoroRepository.to.fetchToday();
      sessions.assignAll(list);
      completedWork.value = todayCompletedSessions;
    } catch (_) {}
  }

  // ── Computed ─────────────────────────────────────────────────────────────────
  int get totalSeconds {
    switch (currentType.value) {
      case PomodoroType.work:       return workMinutes.value * 60;
      case PomodoroType.shortBreak: return shortBreakMinutes.value * 60;
      case PomodoroType.longBreak:  return longBreakMinutes.value * 60;
    }
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds.value / totalSeconds);
  }

  String get timeDisplay {
    final m = remainingSeconds.value ~/ 60;
    final s = remainingSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get sessionLabel {
    switch (currentType.value) {
      case PomodoroType.work:       return 'Tập trung';
      case PomodoroType.shortBreak: return 'Nghỉ ngắn';
      case PomodoroType.longBreak:  return 'Nghỉ dài';
    }
  }

  Color get sessionColor {
    switch (currentType.value) {
      case PomodoroType.work:       return AppColors.pomodoroWork;
      case PomodoroType.shortBreak: return AppColors.pomodoroShortBreak;
      case PomodoroType.longBreak:  return AppColors.pomodoroLongBreak;
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void start() {
    if (status.value == PomodoroStatus.idle ||
        status.value == PomodoroStatus.finished) {
      remainingSeconds.value = totalSeconds;
    }
    status.value = PomodoroStatus.running;
    _currentSession = PomodoroSession(
      type:      currentType.value,
      startedAt: DateTime.now(),
    );
    _startTimer();
  }

  void pause() {
    if (status.value != PomodoroStatus.running) return;
    status.value = PomodoroStatus.paused;
    _timer?.cancel();
  }

  void resume() {
    if (status.value != PomodoroStatus.paused) return;
    status.value = PomodoroStatus.running;
    _startTimer();
  }

  void skip() {
    _timer?.cancel();
    _completeSession(interrupted: true);
    _moveToNextSession();
    status.value = PomodoroStatus.idle;
  }

  void reset() {
    _timer?.cancel();
    status.value          = PomodoroStatus.idle;
    remainingSeconds.value = totalSeconds;
  }

  void setTask(String taskName) {
    currentTask.value = taskName;
  }

  // ── Business Rule: Xác định phiên tiếp theo ──────────────────────────────────
  /// Sau mỗi work session:
  ///   - Nếu completedWork % sessionsUntilLong == 0 → long break
  ///   - Ngược lại → short break
  /// Sau break → work
  void _moveToNextSession() {
    if (currentType.value == PomodoroType.work) {
      completedWork.value++;
      if (completedWork.value % sessionsUntilLong.value == 0) {
        currentType.value = PomodoroType.longBreak;
      } else {
        currentType.value = PomodoroType.shortBreak;
      }
    } else {
      currentType.value = PomodoroType.work;
    }
    remainingSeconds.value = totalSeconds;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        _completeSession();
        status.value = PomodoroStatus.finished;
        _onSessionFinished();
      }
    });
  }

  void _completeSession({bool interrupted = false}) {
    if (_currentSession == null) return;
    _currentSession!.endedAt  = DateTime.now();
    _currentSession!.completed = !interrupted;
    final finished = _currentSession!;
    sessions.add(finished);
    _currentSession = null;
    _syncSession(finished);
  }

  void _syncSession(PomodoroSession session) {
    if (!AuthService.to.useApi) return;
    PomodoroRepository.to
        .create(session, taskTitle: currentTask.value)
        .catchError((_) {});
  }

  void _onSessionFinished() {
    _moveToNextSession();
  }

  // ── Today stats ──────────────────────────────────────────────────────────────
  int get todayFocusMinutes {
    final today = DateTime.now();
    return sessions
        .where((s) =>
    s.type == PomodoroType.work &&
        s.completed &&
        s.startedAt.day == today.day)
        .fold(0, (sum, s) {
      final dur = s.endedAt?.difference(s.startedAt).inMinutes ?? 0;
      return sum + dur;
    });
  }

  int get todayCompletedSessions {
    final today = DateTime.now();
    return sessions
        .where((s) =>
    s.type == PomodoroType.work &&
        s.completed &&
        s.startedAt.day == today.day)
        .length;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}