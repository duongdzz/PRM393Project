import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pomodoro_controller.dart';
import 'widgets/focus_picker_sheet.dart';
import '../../models/pomodoro_model.dart';
import '../tasks/task_controller.dart';
import '../../shared/theme/app_theme.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PomodoroController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Session type selector ──────────────────────────────────────
              _SessionTypeBar(controller: c),

              const SizedBox(height: 40),

              // ── Circular timer ─────────────────────────────────────────────
              _CircularTimer(controller: c),

              const SizedBox(height: 32),

              // ── Session dots (4 pomodoros → long break) ────────────────────
              _SessionDots(controller: c),

              const SizedBox(height: 32),

              // ── Focus time ─────────────────────────────────────────────────
              _FocusSection(controller: c),

              const SizedBox(height: 16),

              // ── Task đang làm ──────────────────────────────────────────────
              _TaskInput(controller: c),

              const SizedBox(height: 28),

              // ── Controls ───────────────────────────────────────────────────
              _Controls(controller: c),

              const SizedBox(height: 32),

              // ── Today stats ────────────────────────────────────────────────
              _TodayStats(controller: c),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Session Type Selector ─────────────────────────────────────────────────────

class _SessionTypeBar extends StatelessWidget {
  final PomodoroController controller;
  const _SessionTypeBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: PomodoroType.values.map((type) {
          final selected = controller.currentType.value == type;
          final label = type == PomodoroType.work
              ? 'Tập trung'
              : type == PomodoroType.shortBreak
              ? 'Nghỉ ngắn'
              : 'Nghỉ dài';
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (controller.status.value == PomodoroStatus.idle ||
                    controller.status.value == PomodoroStatus.finished) {
                  controller.currentType.value = type;
                  controller.remainingSeconds.value = controller.totalSeconds;
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? controller.sessionColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }
}

// ── Circular Timer ────────────────────────────────────────────────────────────

class _CircularTimer extends StatelessWidget {
  final PomodoroController controller;
  const _CircularTimer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () {
        switch (controller.status.value) {
          case PomodoroStatus.idle:
          case PomodoroStatus.finished:
            controller.start();
            break;
          case PomodoroStatus.running:
            controller.pause();
            break;
          case PomodoroStatus.paused:
            controller.resume();
            break;
        }
      },
      child: SizedBox(
        width: 260,
        height: 260,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _TimerPainter(
              progress: controller.progress,
              color:    controller.sessionColor,
            ),
            child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thời gian
                Text(
                  controller.timeDisplay,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: AppColors.onSurface,
                    letterSpacing: -2,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                // Loại phiên
                Text(
                  controller.sessionLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.sessionColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Icon trạng thái (tap hint)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    controller.status.value == PomodoroStatus.running
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    key: ValueKey(controller.status.value),
                    color: AppColors.tertiary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    ));
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  _TimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 8.0;

    // Track (background ring)
    final trackPaint = Paint()
      ..color  = color.withValues(alpha:0.15)
      ..style  = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap   = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap   = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Glow dot at tip
    if (progress > 0.01) {
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dotX  = center.dx + radius * math.cos(angle);
      final dotY  = center.dy + radius * math.sin(angle);
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 1, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_TimerPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Session Dots ──────────────────────────────────────────────────────────────

class _SessionDots extends StatelessWidget {
  final PomodoroController controller;
  const _SessionDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final completed = controller.completedWork.value;
      final total     = controller.sessionsUntilLong;
      final current   = completed % total;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final isDone    = i < current;
          final isCurrent = i == current &&
              controller.currentType.value == PomodoroType.work &&
              controller.status.value == PomodoroStatus.running;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width:  isDone || isCurrent ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.primary
                  : isCurrent
                  ? AppColors.primary.withValues(alpha:0.6)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
      );
    });
  }
}

// ── Focus Section ─────────────────────────────────────────────────────────────

class _FocusSection extends StatelessWidget {
  final PomodoroController controller;
  const _FocusSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ids = controller.focusTaskIds;
      final taskC = Get.find<TaskController>();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.center_focus_strong_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Focus hôm nay',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (ids.isNotEmpty)
                  Text(
                    controller.focusProgressLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (ids.isEmpty)
              const Text(
                'Chưa chọn danh sách ưu tiên. Pomodoro sẽ tự chọn task khi bạn thiết lập Focus.',
                style: TextStyle(color: AppColors.tertiary, fontSize: 12),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ids.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final id  = entry.value;
                  final task = taskC.tasks.firstWhereOrNull((t) => t.id == id);
                  if (task == null) return const SizedBox.shrink();
                  final isActive = idx == controller.focusIndex.value;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showFocusPickerSheet(context),
                icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                label: Text(ids.isEmpty ? 'Chọn task Focus' : 'Sửa danh sách Focus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Task Input ────────────────────────────────────────────────────────────────

class _TaskInput extends StatelessWidget {
  final PomodoroController controller;
  const _TaskInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () => showFocusPickerSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.currentTask.value.isNotEmpty
                ? AppColors.primary.withValues(alpha:0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 18,
              color: controller.currentTask.value.isNotEmpty
                  ? AppColors.primary
                  : AppColors.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentTask.value.isNotEmpty
                        ? controller.currentTask.value
                        : 'Chọn công việc đang làm...',
                    style: TextStyle(
                      color: controller.currentTask.value.isNotEmpty
                          ? AppColors.onSurface
                          : AppColors.tertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (controller.focusTaskIds.isNotEmpty)
                    Text(
                      'Từ danh sách Focus ${controller.focusProgressLabel}',
                      style: const TextStyle(
                        color: AppColors.tertiary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.expand_more_rounded, color: AppColors.tertiary, size: 20),
          ],
        ),
      ),
    ));
  }
}

// ── Controls ──────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  final PomodoroController controller;
  const _Controls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.status.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reset
          _ControlButton(
            icon: Icons.refresh_rounded,
            onTap: controller.reset,
            size: 48,
            color: AppColors.tertiary,
          ),

          const SizedBox(width: 20),

          // Start / Pause / Resume — nút chính
          GestureDetector(
            onTap: () {
              switch (status) {
                case PomodoroStatus.idle:
                case PomodoroStatus.finished:
                  controller.start();
                  break;
                case PomodoroStatus.running:
                  controller.pause();
                  break;
                case PomodoroStatus.paused:
                  controller.resume();
                  break;
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: controller.sessionColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: controller.sessionColor.withValues(alpha:0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                status == PomodoroStatus.running
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Skip
          _ControlButton(
            icon: Icons.skip_next_rounded,
            onTap: controller.skip,
            size: 48,
            color: AppColors.tertiary,
          ),
        ],
      );
    });
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  const _ControlButton({required this.icon, required this.onTap,
    required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}

// ── Today Stats ───────────────────────────────────────────────────────────────

class _TodayStats extends StatelessWidget {
  final PomodoroController controller;
  const _TodayStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatItem(
            value: '${controller.todayCompletedSessions}',
            label: 'Phiên hôm nay',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.error,
          ),
          _divider(),
          _StatItem(
            value: '${controller.todayFocusMinutes}',
            label: 'Phút tập trung',
            icon: Icons.timer_rounded,
            color: AppColors.primary,
          ),
          _divider(),
          _StatItem(
            value: '${controller.completedWork.value}',
            label: 'Tổng Pomodoro',
            icon: Icons.emoji_events_rounded,
            color: AppColors.warning,
          ),
        ],
      ),
    ));
  }

  Widget _divider() => Container(
    width: 1, height: 40,
    color: AppColors.border,
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatItem({required this.value, required this.label,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(
              color: AppColors.onSurface, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(
              color: AppColors.tertiary, fontSize: 11)),
        ],
      ),
    );
  }
}