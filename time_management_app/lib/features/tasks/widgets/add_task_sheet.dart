import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../task_controller.dart';
import '../../../shared/theme/app_theme.dart';

/// Mở bottom sheet thêm công việc mới. Dùng chung cho Home (nút +) và các màn khác.
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
  TaskPriority _priority  = TaskPriority.medium;
  DateTime?    _deadline;
  int _estHours   = 0;
  int _estMinutes = 0;
  int _estSeconds = 0;

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
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Thêm công việc mới',
              style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // Title
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

          // Description
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

          // Priority selector
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

          // Deadline (full width)
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
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
              if (pickedDate == null) return;

              final pickedTime = await showTimePicker(
                context: context,
                initialTime: _deadline != null
                    ? TimeOfDay.fromDateTime(_deadline!)
                    : TimeOfDay.now(),
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

              setState(() {
                _deadline = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime?.hour ?? 0,
                  pickedTime?.minute ?? 0,
                );
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _deadline != null
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.tertiary),
                  const SizedBox(width: 8),
                  Text(
                    _deadline != null
                        ? 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year} '
                            '${_deadline!.hour.toString().padLeft(2, '0')}:${_deadline!.minute.toString().padLeft(2, '0')}'
                        : 'Chọn deadline',
                    style: TextStyle(
                      color: _deadline != null ? AppColors.onSurface : AppColors.tertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Estimated time — wheel picker Giờ / Phút / Giây
          Row(
            children: [
              const Text('Thời gian ước tính',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
              const Spacer(),
              Text(
                _estimateLabel(),
                style: const TextStyle(
                    color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _WheelColumn(
                    label: 'Giờ',
                    count: 24,
                    value: _estHours,
                    onChanged: (v) => setState(() => _estHours = v),
                  ),
                ),
                Expanded(
                  child: _WheelColumn(
                    label: 'Phút',
                    count: 60,
                    value: _estMinutes,
                    onChanged: (v) => setState(() => _estMinutes = v),
                  ),
                ),
                Expanded(
                  child: _WheelColumn(
                    label: 'Giây',
                    count: 60,
                    value: _estSeconds,
                    onChanged: (v) => setState(() => _estSeconds = v),
                  ),
                ),
              ],
            ),
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
      ),
    );
  }

  // Tổng thời gian ước tính quy đổi về phút (làm tròn theo giây).
  int get _estimatedMinutes {
    final totalSeconds = _estHours * 3600 + _estMinutes * 60 + _estSeconds;
    return (totalSeconds / 60).round();
  }

  String _estimateLabel() {
    if (_estHours == 0 && _estMinutes == 0 && _estSeconds == 0) {
      return 'Chưa đặt';
    }
    final parts = <String>[];
    if (_estHours > 0)   parts.add('${_estHours}h');
    if (_estMinutes > 0) parts.add('${_estMinutes}p');
    if (_estSeconds > 0) parts.add('${_estSeconds}s');
    return parts.join(' ');
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tên công việc',
          backgroundColor: AppColors.surface,
          colorText: AppColors.onSurface,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }
    final now = DateTime.now();
    final estimate = _estimatedMinutes;
    widget.controller.addTask(TaskModel(
      id:                 DateTime.now().millisecondsSinceEpoch.toString(),
      title:              _titleCtrl.text.trim(),
      description:        _descCtrl.text.trim(),
      priority:           _priority,
      deadline:           _deadline,
      estimatedMinutes:   estimate > 0 ? estimate : null,
      createdAt:          now,
      updatedAt:          now,
    ));
    Navigator.pop(context);
    Get.snackbar('✓ Đã thêm', _titleCtrl.text.trim(),
        backgroundColor: AppColors.surface,
        colorText: AppColors.onSurface,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12);
  }
}

// ── Wheel column (cuộn chọn số) ───────────────────────────────────────────────
class _WheelColumn extends StatelessWidget {
  final String label;
  final int count;
  final int value;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.label,
    required this.count,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: AppColors.tertiary, fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          height: 120,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: value),
            itemExtent: 34,
            backgroundColor: Colors.transparent,
            squeeze: 1.1,
            selectionOverlay: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                ),
              ),
            ),
            onSelectedItemChanged: onChanged,
            children: List.generate(
              count,
              (i) => Center(
                child: Text(
                  i.toString().padLeft(2, '0'),
                  style: const TextStyle(color: AppColors.onSurface, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
