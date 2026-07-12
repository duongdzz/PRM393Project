import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'task_mapper.dart';

class TaskRepository {
  TaskRepository._();
  static TaskRepository get to => TaskRepository._();

  Future<List<TaskModel>> fetchAll() async {
    if (!AuthService.to.useApi) return [];

    final data = await ApiService.to.get('/api/tasks');
    return (data as List<dynamic>)
        .map((e) => TaskMapper.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> create(TaskModel task) async {
    final data = await ApiService.to.post(
      '/api/tasks',
      body: TaskMapper.toCreateJson(task),
    );
    return TaskMapper.fromJson(data as Map<String, dynamic>);
  }

  Future<TaskModel> complete(String taskId, DateTime onDate) async {
    final date = dateKey(onDate);
    final data = await ApiService.to.post(
      '/api/tasks/$taskId/complete',
      body: {},
      queryParams: {'date': date},
    );
    return TaskMapper.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String taskId) async {
    if (!AuthService.to.useApi) return;
    await ApiService.to.delete('/api/tasks/$taskId');
  }
}
