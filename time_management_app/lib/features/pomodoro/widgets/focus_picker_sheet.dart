import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/task_model.dart';
import '../../tasks/task_controller.dart';
import '../pomodoro_controller.dart';
import '../../../shared/theme/app_theme.dart';

void showFocusPickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceVariant,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const FocusPickerSheet(),
  );
}

class FocusPickerSheet extends StatefulWidget {
  const FocusPickerSheet({super.key});

  @override
  State<FocusPickerSheet> createState() => _FocusPickerSheetState();
}

class _FocusPickerSheetState extends State<FocusPickerSheet> {
  final _pomoC  = Get.find<PomodoroController>();
  final _taskC  = Get.find<TaskController>();
  late Set<String> _selected;
  String? _warning;

  @override
  void initState() {
    super.initState();
    _selected = _pomoC.focusTaskIds.toSet();
    _updateWarning();
  }

  List<TaskModel> get _todayTasks {
    final today = dateOnly(DateTime.now());
    return _taskC.tasksOn(today)
        .where((t) => !_taskC.isDoneOn(t, today))
        .toList();
  }

  void _updateWarning() {
    final unpicked = _pomoC.getUnpickedRecurringTasks(_selected.toList());
    if (unpicked.isEmpty) {
      _warning = null;
    } else {
      _warning =
          'Có ${unpicked.length} việc lặp lại hôm nay chưa được chọn: '
          '${unpicked.map((t) => t.title).join(', ')}';
    }
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      _updateWarning();
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      Get.snackbar(
        'Chưa chọn task',
        'Hãy chọn ít nhất 1 công việc cho Focus hôm nay.',
        backgroundColor: AppColors.surface,
        colorText: AppColors.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final unpicked = _pomoC.getUnpickedRecurringTasks(_selected.toList());
    if (unpicked.isNotEmpty) {
      final proceed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Việc lặp lại chưa chọn'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Các công việc lặp lại hôm nay sau chưa có trong danh sách Focus:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...unpicked.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${t.title}',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                        )),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Bạn vẫn muốn lưu danh sách Focus?',
                    style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Quay lại'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Vẫn lưu'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    await _pomoC.saveFocusList(_selected.toList());
    if (!mounted) return;
    Navigator.pop(context);
    Get.snackbar(
      'Focus hôm nay',
      'Đã chọn ${_selected.length} công việc ưu tiên',
      backgroundColor: AppColors.surface,
      colorText: AppColors.onSurface,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _todayTasks;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Focus hôm nay',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chọn công việc ưu tiên — Pomodoro sẽ làm lần lượt theo thứ tự',
            style: TextStyle(color: AppColors.tertiary, fontSize: 12),
          ),
          if (_warning != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _warning!,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Không có công việc cần làm hôm nay',
                  style: TextStyle(color: AppColors.tertiary),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tasks.length,
                itemBuilder: (_, i) {
                  final task = tasks[i];
                  final checked = _selected.contains(task.id);
                  return CheckboxListTile(
                    value: checked,
                    activeColor: AppColors.primary,
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      task.recurrence.label,
                      style: const TextStyle(
                        color: AppColors.tertiary,
                        fontSize: 12,
                      ),
                    ),
                    secondary: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: priorityColor(task.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    onChanged: (_) => _toggle(task.id),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lưu Focus (${_selected.length})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
