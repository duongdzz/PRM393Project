import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../task_controller.dart';
import '../../../shared/theme/app_theme.dart';

void showAddTaskSheet(BuildContext context, TaskController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceVariant,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => AddTaskSheet(controller: controller),
  );
}

class AddTaskSheet extends StatefulWidget {
  final TaskController controller;
  const AddTaskSheet({super.key, required this.controller});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  RecurrenceType _recurrence = RecurrenceType.daily;
  DateTime _startDate = dateOnly(DateTime.now());
  DateTime? _deadline;
  final Set<int> _weekDays = {DateTime.now().weekday};

  static const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Thêm công việc',
                style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Ưu tiên công việc lặp lại hàng ngày / hàng tuần',
                style: TextStyle(color: AppColors.tertiary, fontSize: 12)),
            const SizedBox(height: 20),

            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Tên công việc *',
                hintStyle: TextStyle(color: AppColors.tertiary.withOpacity(0.7)),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descCtrl,
              style: const TextStyle(color: AppColors.onSurface),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Mô tả (tuỳ chọn)',
                hintStyle: TextStyle(color: AppColors.tertiary.withOpacity(0.7)),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Lặp lại', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RecurrenceType.values.map((r) {
                final selected = _recurrence == r;
                return GestureDetector(
                  onTap: () => setState(() => _recurrence = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      r.label,
                      style: TextStyle(
                        color: selected ? AppColors.primary : AppColors.tertiary,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_recurrence == RecurrenceType.weekly) ...[
              const SizedBox(height: 12),
              const Text('Các ngày trong tuần',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(7, (i) {
                  final weekday = i + 1;
                  final selected = _weekDays.contains(weekday);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (selected && _weekDays.length > 1) {
                          _weekDays.remove(weekday);
                        } else {
                          _weekDays.add(weekday);
                        }
                      }),
                      child: Container(
                        margin: EdgeInsets.only(right: i < 6 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          _weekdayLabels[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? AppColors.primary : AppColors.tertiary,
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],

            const SizedBox(height: 16),

            const Text('Ưu tiên', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
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
                            : AppColors.inputFill,
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

            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _recurrence == RecurrenceType.once
                      ? (_deadline ?? DateTime.now().add(const Duration(days: 1)))
                      : _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: AppColors.onSurface,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked == null) return;
                setState(() {
                  if (_recurrence == RecurrenceType.once) {
                    _deadline = picked;
                  } else {
                    _startDate = dateOnly(picked);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.tertiary),
                    const SizedBox(width: 8),
                    Text(
                      _recurrence == RecurrenceType.once
                          ? (_deadline != null
                              ? 'Ngày: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                              : 'Chọn ngày (một lần)')
                          : 'Bắt đầu từ: ${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tên công việc',
          backgroundColor: AppColors.surface,
          colorText: AppColors.onSurface,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }
    if (_recurrence == RecurrenceType.once && _deadline == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn ngày cho công việc một lần',
          backgroundColor: AppColors.surface,
          colorText: AppColors.onSurface,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }

    final now = DateTime.now();
    final weekDays = _recurrence == RecurrenceType.weekly
        ? (List<int>.from(_weekDays)..sort())
        : <int>[];

    final error = await widget.controller.addTask(TaskModel(
      id:          DateTime.now().millisecondsSinceEpoch.toString(),
      title:       _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priority:    _priority,
      recurrence:  _recurrence,
      deadline:    _recurrence == RecurrenceType.once ? _deadline : null,
      startDate:   _recurrence == RecurrenceType.once ? null : _startDate,
      weekDays:    weekDays,
      createdAt:   now,
      updatedAt:   now,
    ));
    if (error != null) {
      if (!mounted) return;
      Get.snackbar('Lỗi', error,
          backgroundColor: AppColors.surface,
          colorText: AppColors.onSurface,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
    Get.snackbar('✓ Đã thêm', _titleCtrl.text.trim(),
        backgroundColor: AppColors.surface,
        colorText: AppColors.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12);
  }
}
