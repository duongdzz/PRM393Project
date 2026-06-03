import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'task_controller.dart';
import '../../shared/theme/app_theme.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TaskController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: Column(
        children: [
          // ── Header: search + filter ──────────────────────────────────────
          _Header(controller: c),

          // ── Filter chips ────────────────────────────────────────────────
          _FilterBar(controller: c),

          // ── Task list ───────────────────────────────────────────────────
          Expanded(child: _TaskList(controller: c)),
        ],
      ),

      // ── FAB thêm task ────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context, c),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm task',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, TaskController c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddTaskSheet(controller: c),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TaskController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: TextField(
                onChanged: (v) => controller.searchQuery.value = v,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm công việc...',
                  hintStyle: TextStyle(color: AppColors.tertiary.withOpacity(0.7), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.tertiary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Sort button
          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Icon(Icons.sort_rounded, color: AppColors.tertiary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sắp xếp theo',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...{
              'deadline':  'Deadline gần nhất',
              'priority':  'Ưu tiên cao nhất',
              'createdAt': 'Mới tạo nhất',
            }.entries.map((e) => Obx(() => ListTile(
              title: Text(e.value, style: const TextStyle(color: Colors.white)),
              trailing: controller.sortBy.value == e.key
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                controller.sortBy.value = e.key;
                Navigator.pop(context);
              },
            ))),
          ],
        ),
      ),
    );
  }
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TaskController controller;
  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = <String, TaskStatus?>{
      'Tất cả':       null,
      'Cần làm':      TaskStatus.todo,
      'Đang làm':     TaskStatus.inProgress,
      'Hoàn thành':   TaskStatus.done,
    };

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: filters.entries.map((e) => Obx(() {
          final selected = controller.filterStatus.value == e.value;
          return GestureDetector(
            onTap: () => controller.filterStatus.value = e.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Text(
                e.key,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.tertiary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        })).toList(),
      ),
    );
  }
}

// ── Task List ─────────────────────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  final TaskController controller;
  const _TaskList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filteredTasks;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt_rounded, color: AppColors.tertiary.withOpacity(0.3), size: 56),
              const SizedBox(height: 12),
              Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'Không tìm thấy công việc'
                    : 'Chưa có công việc nào',
                style: TextStyle(color: AppColors.tertiary.withOpacity(0.7), fontSize: 15),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: list.length,
        itemBuilder: (_, i) => _TaskCard(task: list[i], controller: controller),
      );
    });
  }
}

// ── Task Card ─────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final TaskController controller;
  const _TaskCard({required this.task, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surfaceVariant,
            title: const Text('Xoá công việc?', style: TextStyle(color: Colors.white)),
            content: Text('Xoá "${task.title}"?',
                style: const TextStyle(color: AppColors.tertiary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xoá', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => controller.deleteTask(task.id),
      child: GestureDetector(
        onTap: () => _showTaskDetail(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: task.isOverdue
                  ? AppColors.error.withOpacity(0.4)
                  : task.isDueSoon
                  ? AppColors.warning.withOpacity(0.3)
                  : Colors.white.withOpacity(0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority dot
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _priorityColor(task.priority).withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Title
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: task.status == TaskStatus.done
                            ? AppColors.tertiary
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),

                  // Status chip
                  _StatusChip(status: task.status),
                ],
              ),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.tertiary, fontSize: 12),
                ),
              ],

              const SizedBox(height: 12),

              Row(
                children: [
                  // Deadline
                  if (task.deadline != null) ...[
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: task.isOverdue
                          ? AppColors.error
                          : task.isDueSoon
                          ? AppColors.warning
                          : AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _deadlineText(task.deadline!),
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isOverdue
                            ? AppColors.error
                            : task.isDueSoon
                            ? AppColors.warning
                            : AppColors.tertiary,
                        fontWeight: task.isOverdue || task.isDueSoon
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Sub-tasks progress
                  if (task.subTasks.isNotEmpty) ...[
                    Icon(Icons.checklist_rounded, size: 13, color: AppColors.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${task.subTasks.where((s) => s.isDone).length}/${task.subTasks.length}',
                      style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
                    ),
                  ],

                  const Spacer(),

                  // Mark done button
                  if (task.status != TaskStatus.done && task.status != TaskStatus.cancelled)
                    GestureDetector(
                      onTap: () {
                        final error = controller.tryMarkDone(task.id);
                        if (error != null) {
                          Get.snackbar(
                            'Không thể hoàn thành',
                            error,
                            backgroundColor: AppColors.surfaceVariant,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            icon: const Icon(Icons.warning_amber_rounded,
                                color: AppColors.warning),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'Hoàn thành',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Progress bar nếu có estimated time
              if (task.estimatedMinutes != null && task.estimatedMinutes! > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.progressPercent,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            task.progressPercent >= 1.0
                                ? AppColors.warning
                                : AppColors.primary,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${task.actualMinutes}/${task.estimatedMinutes}p',
                      style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _deadlineText(DateTime deadline) {
    final now  = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return 'Quá hạn ${(-diff.inHours)}h';
    if (diff.inHours < 1) return 'Còn ${diff.inMinutes}p';
    if (diff.inHours < 24) return 'Còn ${diff.inHours}h';
    return '${deadline.day}/${deadline.month}';
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:    return AppColors.tertiary;
      case TaskPriority.medium: return AppColors.primary;
      case TaskPriority.high:   return AppColors.warning;
      case TaskPriority.urgent: return AppColors.error;
    }
  }

  void _showTaskDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _TaskDetailSheet(task: task, controller: controller),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final TaskStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TaskStatus.todo       => ('Cần làm',    AppColors.tertiary),
      TaskStatus.inProgress => ('Đang làm',   AppColors.primary),
      TaskStatus.done       => ('Xong',       AppColors.success),
      TaskStatus.cancelled  => ('Huỷ',        AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Task Detail Sheet ─────────────────────────────────────────────────────────

class _TaskDetailSheet extends StatelessWidget {
  final TaskModel task;
  final TaskController controller;
  const _TaskDetailSheet({required this.task, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title + priority
            Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: _priorityColor(task.priority),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(task.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ],
            ),

            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(task.description,
                  style: const TextStyle(color: AppColors.tertiary, fontSize: 14, height: 1.5)),
            ],

            const SizedBox(height: 20),

            // Info row
            Wrap(
              spacing: 12, runSpacing: 8,
              children: [
                if (task.deadline != null)
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: '${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}',
                    color: task.isOverdue ? AppColors.error : AppColors.tertiary,
                  ),
                _InfoChip(
                  icon: Icons.flag_rounded,
                  label: _priorityLabel(task.priority),
                  color: _priorityColor(task.priority),
                ),
                if (task.estimatedMinutes != null)
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${task.estimatedMinutes}p ước tính',
                    color: AppColors.tertiary,
                  ),
              ],
            ),

            if (task.estimatedMinutes != null) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tiến độ thời gian',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text('${task.actualMinutes}/${task.estimatedMinutes} phút',
                      style: const TextStyle(color: AppColors.tertiary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: task.progressPercent,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    task.progressPercent >= 1.0 ? AppColors.warning : AppColors.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ],

            // Sub-tasks
            if (task.subTasks.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Công việc con',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...task.subTasks.map((sub) => Obx(() => CheckboxListTile(
                value: sub.isDone,
                onChanged: (_) => controller.toggleSubTask(task.id, sub.id),
                title: Text(
                  sub.title,
                  style: TextStyle(
                    color: sub.isDone ? AppColors.tertiary : Colors.white,
                    decoration: sub.isDone ? TextDecoration.lineThrough : null,
                    fontSize: 14,
                  ),
                ),
                activeColor: AppColors.primary,
                checkColor: Colors.white,
                contentPadding: EdgeInsets.zero,
              ))),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: navigate to PomodoroScreen với task này
                    },
                    icon: const Icon(Icons.timer_rounded, size: 18),
                    label: const Text('Bắt đầu Pomodoro'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final error = controller.tryMarkDone(task.id);
                      if (error != null) {
                        Get.snackbar('Không thể hoàn thành', error,
                          backgroundColor: AppColors.surfaceVariant,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Hoàn thành'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:    return AppColors.tertiary;
      case TaskPriority.medium: return AppColors.primary;
      case TaskPriority.high:   return AppColors.warning;
      case TaskPriority.urgent: return AppColors.error;
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:    return 'Thấp';
      case TaskPriority.medium: return 'Trung bình';
      case TaskPriority.high:   return 'Cao';
      case TaskPriority.urgent: return 'Khẩn cấp';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Add Task Sheet ────────────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final TaskController controller;
  const _AddTaskSheet({required this.controller});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  TaskPriority _priority  = TaskPriority.medium;
  DateTime?    _deadline;
  int?         _estimated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Thêm công việc mới',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // Title
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tên công việc *',
              hintStyle: TextStyle(color: AppColors.tertiary.withOpacity(0.7)),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Mô tả (tuỳ chọn)',
              hintStyle: TextStyle(color: AppColors.tertiary.withOpacity(0.7)),
              filled: true,
              fillColor: const Color(0xFF1A2332),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // Priority selector
          const Text('Ưu tiên', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: TaskPriority.values.map((p) {
              final labels = ['Thấp', 'TB', 'Cao', 'Khẩn'];
              final colors = [AppColors.tertiary, AppColors.primary, AppColors.warning, AppColors.error];
              final selected = _priority == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: p != TaskPriority.urgent ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors[p.index].withOpacity(0.2)
                          : const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? colors[p.index] : Colors.transparent,
                      ),
                    ),
                    child: Text(labels[p.index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? colors[p.index] : AppColors.tertiary,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Deadline + Estimated time
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _deadline = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _deadline != null
                            ? AppColors.primary.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: AppColors.tertiary),
                        const SizedBox(width: 8),
                        Text(
                          _deadline != null
                              ? '${_deadline!.day}/${_deadline!.month}'
                              : 'Deadline',
                          style: TextStyle(
                            color: _deadline != null ? Colors.white : AppColors.tertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _estimated = int.tryParse(v),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Phút ước tính',
                    hintStyle: TextStyle(color: AppColors.tertiary.withOpacity(0.7), fontSize: 13),
                    prefixIcon: const Icon(Icons.timer_outlined, size: 16, color: AppColors.tertiary),
                    filled: true,
                    fillColor: const Color(0xFF1A2332),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Thêm công việc',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tên công việc',
          backgroundColor: AppColors.surfaceVariant,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return;
    }
    final now = DateTime.now();
    widget.controller.addTask(TaskModel(
      id:                 DateTime.now().millisecondsSinceEpoch.toString(),
      title:              _titleCtrl.text.trim(),
      description:        _descCtrl.text.trim(),
      priority:           _priority,
      deadline:           _deadline,
      estimatedMinutes:   _estimated,
      createdAt:          now,
      updatedAt:          now,
    ));
    Navigator.pop(context);
    Get.snackbar('✓ Đã thêm', _titleCtrl.text.trim(),
        backgroundColor: AppColors.surfaceVariant,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12);
  }
}