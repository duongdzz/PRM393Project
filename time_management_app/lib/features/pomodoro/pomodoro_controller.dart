import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../models/pomodoro_model.dart';
import '../../models/task_model.dart';
import '../../data/pomodoro_repository.dart';
import '../../shared/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../tasks/task_controller.dart';

class PomodoroController extends GetxController with WidgetsBindingObserver {
  // ── Settings (phút) ──────────────────────────────────────────────────────────
  final int workMinutes       = 25;
  final int shortBreakMinutes = 5;
  final int longBreakMinutes  = 15;
  final int sessionsUntilLong = 4;

  // ── State ────────────────────────────────────────────────────────────────────
  final status           = PomodoroStatus.idle.obs;
  final currentType      = PomodoroType.work.obs;
  final remainingSeconds = (25 * 60).obs;
  final completedWork    = 0.obs;
  final currentTask      = ''.obs;

  // ── Focus list ─────────────────────────────────────────────────────────────
  final focusTaskIds = <String>[].obs;
  final focusIndex   = 0.obs;

  // ── History ──────────────────────────────────────────────────────────────────
  final sessions = <PomodoroSession>[].obs;

  Timer? _timer;
  PomodoroSession? _currentSession;
  DateTime? _endsAt;

  static const _keyFocusIds   = 'focus_task_ids';
  static const _keyFocusDate  = 'focus_date';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadFocusList();
    loadSessions();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _disableBackground();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        status.value == PomodoroStatus.running) {
      _syncFromClock();
    }
  }

  Future<void> loadSessions() async {
    if (!AuthService.to.useApi) return;

    try {
      final list = await PomodoroRepository.to.fetchToday();
      sessions.assignAll(list);
      completedWork.value = todayCompletedSessions;
    } catch (_) {}
  }

  // ── Focus list logic ─────────────────────────────────────────────────────────

  List<TaskModel> getUnpickedRecurringTasks(List<String> pickedIds) {
    final taskC = Get.find<TaskController>();
    final today = dateOnly(DateTime.now());
    final picked = pickedIds.toSet();
    return taskC
        .tasksOn(today)
        .where((t) => !taskC.isDoneOn(t, today))
        .where((t) => t.isRecurring && !picked.contains(t.id))
        .toList();
  }

  Future<void> saveFocusList(List<String> ids) async {
    final taskC = Get.find<TaskController>();
    final sorted = ids
        .map((id) => taskC.tasks.firstWhereOrNull((t) => t.id == id))
        .whereType<TaskModel>()
        .toList()
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

    focusTaskIds.assignAll(sorted.map((t) => t.id));
    focusIndex.value = 0;
    applyCurrentFocusTask();
    await _persistFocusList();
  }

  void applyCurrentFocusTask() {
    if (focusTaskIds.isEmpty) return;

    final idx = focusIndex.value.clamp(0, focusTaskIds.length - 1);
    focusIndex.value = idx;

    final taskC = Get.find<TaskController>();
    final task = taskC.tasks.firstWhereOrNull((t) => t.id == focusTaskIds[idx]);
    if (task != null) currentTask.value = task.title;
  }

  void advanceFocusTask() {
    if (focusTaskIds.isEmpty) return;
    if (focusIndex.value < focusTaskIds.length - 1) {
      focusIndex.value++;
      applyCurrentFocusTask();
    }
  }

  String get focusProgressLabel {
    if (focusTaskIds.isEmpty) return '';
    return '${focusIndex.value + 1}/${focusTaskIds.length}';
  }

  Future<void> _loadFocusList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keyFocusDate) ?? '';
    final todayKey  = dateKey(DateTime.now());

    if (savedDate != todayKey) {
      focusTaskIds.clear();
      focusIndex.value = 0;
      await prefs.remove(_keyFocusIds);
      await prefs.setString(_keyFocusDate, todayKey);
      return;
    }

    final raw = prefs.getString(_keyFocusIds);
    if (raw == null) return;

    final ids = (jsonDecode(raw) as List<dynamic>).cast<String>();
    focusTaskIds.assignAll(ids);
    applyCurrentFocusTask();
  }

  Future<void> _persistFocusList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFocusDate, dateKey(DateTime.now()));
    await prefs.setString(_keyFocusIds, jsonEncode(focusTaskIds));
  }

  // ── Computed ─────────────────────────────────────────────────────────────────

  int get totalSeconds {
    switch (currentType.value) {
      case PomodoroType.work:       return workMinutes * 60;
      case PomodoroType.shortBreak: return shortBreakMinutes * 60;
      case PomodoroType.longBreak:  return longBreakMinutes * 60;
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
      if (currentType.value == PomodoroType.work) {
        if (focusTaskIds.isNotEmpty) applyCurrentFocusTask();
      }
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
    _endsAt = null;
    _disableBackground();
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
    _endsAt = null;
    _disableBackground();
  }

  void reset() {
    _timer?.cancel();
    status.value           = PomodoroStatus.idle;
    remainingSeconds.value = totalSeconds;
    _endsAt = null;
    _disableBackground();
  }

  void _moveToNextSession() {
    if (currentType.value == PomodoroType.work) {
      completedWork.value++;
      if (completedWork.value % sessionsUntilLong == 0) {
        currentType.value = PomodoroType.longBreak;
      } else {
        currentType.value = PomodoroType.shortBreak;
      }
    } else {
      currentType.value = PomodoroType.work;
      applyCurrentFocusTask();
    }
    remainingSeconds.value = totalSeconds;
  }

  void _startTimer() {
    _endsAt = DateTime.now().add(Duration(seconds: remainingSeconds.value));
    _enableBackground();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncFromClock();
    });
  }

  void _syncFromClock() {
    if (_endsAt == null) return;

    final left = _endsAt!.difference(DateTime.now()).inSeconds;
    if (left > 0) {
      remainingSeconds.value = left;
      return;
    }

    remainingSeconds.value = 0;
    _timer?.cancel();
    _finishSession();
  }

  void _finishSession() {
    final finishedType = currentType.value;
    final finishedLabel = sessionLabel;
    final finishedTask  = currentTask.value;

    _completeSession();
    status.value = PomodoroStatus.finished;

    NotificationService.to.cancelPomodoroEnd();
    NotificationService.to.showSessionComplete(
      sessionLabel: finishedLabel,
      taskTitle: finishedTask,
    );

    Get.snackbar(
      'Hết giờ!',
      finishedTask.isNotEmpty
          ? '$finishedLabel — $finishedTask'
          : finishedLabel,
      backgroundColor: AppColors.surface,
      colorText: AppColors.onSurface,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );

    if (finishedType == PomodoroType.work) {
      advanceFocusTask();
    }

    _onSessionFinished();
    _disableBackground();
    _endsAt = null;
  }

  void _completeSession({bool interrupted = false}) {
    if (_currentSession == null) return;
    _currentSession!.endedAt   = DateTime.now();
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

  Future<void> _enableBackground() async {
    await WakelockPlus.enable();
    if (_endsAt != null) {
      await NotificationService.to.schedulePomodoroEnd(
        endsAt: _endsAt!,
        sessionLabel: sessionLabel,
        taskTitle: currentTask.value,
      );
    }
  }

  Future<void> _disableBackground() async {
    await WakelockPlus.disable();
    await NotificationService.to.cancelPomodoroEnd();
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
}
