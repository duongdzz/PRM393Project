import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'task_mapper.dart';

/// Lưu task local cho chế độ Khách — dữ liệu giữ lại khi tắt/mở lại app.
class LocalTaskStore {
  LocalTaskStore._();
  static LocalTaskStore get to => LocalTaskStore._();

  static const _key = 'local_guest_tasks';

  Future<List<TaskModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TaskMapper.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map(TaskMapper.toJson).toList());
    await prefs.setString(_key, encoded);
  }
}
