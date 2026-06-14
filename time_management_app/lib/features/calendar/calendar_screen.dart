import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../tasks/task_controller.dart';
import '../../shared/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskController _c = Get.put(TaskController());

  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  static const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static const _monthNames = [
    'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
    'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay  = DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<TaskModel> _tasksOn(DateTime day) => _c.tasksOn(day);

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildMonthHeader(),
          _buildWeekdayRow(),
          // Lưới ngày tự cập nhật khi task thay đổi (chấm báo task)
          Obx(() => _buildDayGrid()),
          const SizedBox(height: 8),
          Expanded(child: Obx(() => _buildTaskListForDay())),
        ],
      ),
    );
  }

  // ── Month header ──────────────────────────────────────────────────────────
  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(
            '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _roundIconButton(Icons.chevron_left_rounded, () => _changeMonth(-1)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final now = DateTime.now();
              setState(() {
                _focusedMonth = DateTime(now.year, now.month);
                _selectedDay  = DateTime(now.year, now.month, now.day);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Hôm nay',
                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          _roundIconButton(Icons.chevron_right_rounded, () => _changeMonth(1)),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.onSurface, size: 22),
      ),
    );
  }

  // ── Weekday labels ──────────────────────────────────────────────────────────
  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: _weekdayLabels
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: d == 'CN' ? AppColors.error : AppColors.tertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ── Day grid ──────────────────────────────────────────────────────────────
  Widget _buildDayGrid() {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday - 1; // Mon-first
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - leadingBlanks + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final isSelected = _isSameDay(date, _selectedDay);
              final isToday = _isSameDay(date, today);
              final hasTasks = _tasksOn(date).isNotEmpty;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = date),
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1.2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (col == 6 ? AppColors.error : AppColors.onSurface),
                            fontSize: 14,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasTasks
                                ? (isSelected ? Colors.white : AppColors.warning)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  // ── Task list for selected day ──────────────────────────────────────────────
  Widget _buildTaskListForDay() {
    final tasks = _tasksOn(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Text(
                'Ngày ${_selectedDay.day}/${_selectedDay.month}',
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tasks.length} công việc',
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available_rounded,
                          color: AppColors.tertiary.withOpacity(0.3), size: 52),
                      const SizedBox(height: 10),
                      Text('Không có công việc ngày này',
                          style: TextStyle(color: AppColors.tertiary.withOpacity(0.7), fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: tasks.length,
                  itemBuilder: (_, i) => _CalendarTaskTile(
                        task: tasks[i],
                        controller: _c,
                        occurrenceDate: _selectedDay,
                      ),
                ),
        ),
      ],
    );
  }
}

// ── Task tile ─────────────────────────────────────────────────────────────────
class _CalendarTaskTile extends StatelessWidget {
  final TaskModel task;
  final TaskController controller;
  final DateTime occurrenceDate;
  const _CalendarTaskTile({
    required this.task,
    required this.controller,
    required this.occurrenceDate,
  });

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:    return AppColors.tertiary;
      case TaskPriority.medium: return AppColors.primary;
      case TaskPriority.high:   return AppColors.warning;
      case TaskPriority.urgent: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = controller.isDoneOn(task, occurrenceDate);
    final subtitle = task.isRecurring
        ? task.recurrence.label
        : (task.deadline != null
            ? '${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}'
            : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: _priorityColor(task.priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: isDone ? AppColors.tertiary : AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      task.isRecurring ? Icons.repeat_rounded : Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(subtitle,
                        style: const TextStyle(color: AppColors.tertiary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          if (!isDone)
            GestureDetector(
              onTap: () {
                final error = controller.tryMarkDone(task.id, onDate: occurrenceDate);
                if (error != null) {
                  Get.snackbar('Không thể hoàn thành', error,
                      backgroundColor: AppColors.surfaceVariant,
                      colorText: AppColors.onSurface,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12);
                }
              },
              child: const Icon(Icons.radio_button_unchecked_rounded,
                  color: AppColors.tertiary, size: 22),
            )
          else
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
        ],
      ),
    );
  }
}
