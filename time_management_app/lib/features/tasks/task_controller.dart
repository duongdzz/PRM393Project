import 'package:get/get.dart';

enum TaskStatus   { todo, inProgress, done, cancelled }
enum TaskPriority { low, medium, high, urgent }

class TaskModel {
  final String id;
  String title;
  String description;
  TaskStatus   status;
  TaskPriority priority;
  String   category;
  int?     estimatedMinutes;
  int      actualMinutes;
  DateTime? deadline;
  DateTime  createdAt;
  DateTime  updatedAt;
  List<SubTask> subTasks;

  TaskModel({
    required this.id,
    required this.title,
    this.description    = '',
    this.status         = TaskStatus.todo,
    this.priority       = TaskPriority.medium,
    this.category       = '',
    this.estimatedMinutes,
    this.actualMinutes  = 0,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.subTasks       = const [],
  });

  bool get isOverdue =>
      deadline != null &&
          deadline!.isBefore(DateTime.now()) &&
          status != TaskStatus.done &&
          status != TaskStatus.cancelled;

  bool get isDueSoon =>
      deadline != null &&
          deadline!.difference(DateTime.now()).inHours <= 24 &&
          !isOverdue;

  double get progressPercent {
    if (estimatedMinutes == null || estimatedMinutes == 0) return 0;
    return (actualMinutes / estimatedMinutes!).clamp(0.0, 1.0);
  }

  // Business Rule: không cho done nếu còn sub-task chưa xong
  bool get canMarkDone =>
      subTasks.every((s) => s.isDone);
}

class SubTask {
  final String id;
  String title;
  bool isDone;

  SubTask({required this.id, required this.title, this.isDone = false});
}

// ─────────────────────────────────────────────────────────────────────────────

class TaskController extends GetxController {
  final tasks         = <TaskModel>[].obs;
  final isLoading     = false.obs;
  final searchQuery   = ''.obs;
  final filterStatus  = Rx<TaskStatus?>(null);
  final sortBy        = 'deadline'.obs; // deadline | priority | createdAt

  // ── Filtered & sorted list ────────────────────────────────────────────────
  List<TaskModel> get filteredTasks {
    var list = tasks.where((t) {
      // Không hiển thị cancelled trừ khi lọc rõ ràng
      if (filterStatus.value == null && t.status == TaskStatus.cancelled) {
        return false;
      }
      if (filterStatus.value != null && t.status != filterStatus.value) {
        return false;
      }
      if (searchQuery.value.isNotEmpty) {
        return t.title.toLowerCase().contains(searchQuery.value.toLowerCase());
      }
      return true;
    }).toList();

    // Sort
    switch (sortBy.value) {
      case 'priority':
        list.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'createdAt':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default: // deadline
        list.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
    }

    // Business Rule: urgent luôn lên đầu
    list.sort((a, b) {
      if (a.priority == TaskPriority.urgent && b.priority != TaskPriority.urgent) return -1;
      if (b.priority == TaskPriority.urgent && a.priority != TaskPriority.urgent) return 1;
      return 0;
    });

    return list;
  }

  List<TaskModel> get todayTasks {
    final today = DateTime.now();
    return tasks.where((t) =>
    t.deadline != null &&
        t.deadline!.day   == today.day &&
        t.deadline!.month == today.month &&
        t.deadline!.year  == today.year &&
        t.status != TaskStatus.done &&
        t.status != TaskStatus.cancelled
    ).toList();
  }

  List<TaskModel> get overdueTasks =>
      tasks.where((t) => t.isOverdue).toList();

  // ── CRUD ──────────────────────────────────────────────────────────────────

  void addTask(TaskModel task) {
    tasks.add(task);
    // TODO: gọi API POST /api/tasks
  }

  void updateTask(TaskModel updated) {
    final i = tasks.indexWhere((t) => t.id == updated.id);
    if (i != -1) {
      tasks[i] = updated;
      tasks.refresh();
      // TODO: gọi API PUT /api/tasks/{id}
    }
  }

  // Business Rule: không cho done nếu còn sub-task chưa xong
  String? tryMarkDone(String taskId) {
    final task = tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return 'Task không tồn tại';
    if (!task.canMarkDone) {
      return 'Còn ${task.subTasks.where((s) => !s.isDone).length} công việc con chưa hoàn thành';
    }
    task.status = TaskStatus.done;
    task.updatedAt = DateTime.now();
    tasks.refresh();
    return null; // null = thành công
  }

  void deleteTask(String taskId) {
    tasks.removeWhere((t) => t.id == taskId);
    // TODO: gọi API DELETE /api/tasks/{id}
  }

  void toggleSubTask(String taskId, String subTaskId) {
    final task = tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return;
    final sub = task.subTasks.firstWhereOrNull((s) => s.id == subTaskId);
    if (sub == null) return;
    sub.isDone = !sub.isDone;
    task.updatedAt = DateTime.now();
    tasks.refresh();
  }

  // ── Mock data (xoá khi có API) ────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    tasks.addAll([
      TaskModel(
        id: '1', title: 'Làm báo cáo Flutter',
        description: 'Viết báo cáo project quản lý thời gian',
        priority: TaskPriority.urgent,
        deadline: now.add(const Duration(hours: 3)),
        estimatedMinutes: 120, actualMinutes: 45,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
        subTasks: [
          SubTask(id: 's1', title: 'Viết phần mở đầu', isDone: true),
          SubTask(id: 's2', title: 'Vẽ sơ đồ kiến trúc'),
          SubTask(id: 's3', title: 'Kết luận'),
        ],
      ),
      TaskModel(
        id: '2', title: 'Ôn tập GetX State Management',
        priority: TaskPriority.high,
        deadline: now.add(const Duration(days: 1)),
        estimatedMinutes: 60,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
      TaskModel(
        id: '3', title: 'Đọc tài liệu Material You',
        priority: TaskPriority.medium,
        deadline: now.add(const Duration(days: 3)),
        estimatedMinutes: 45,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: '4', title: 'Code màn hình Profile',
        priority: TaskPriority.medium,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }
}