import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  static const _keyDailyGoal = 'daily_goal_minutes';
  static const defaultDailyGoalMinutes = 480;

  final currentIndex = 0.obs;
  final dailyGoalMinutes = defaultDailyGoalMinutes.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDailyGoal();
  }

  Future<void> _loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_keyDailyGoal);
    if (saved != null && saved > 0) {
      dailyGoalMinutes.value = saved;
    }
  }

  Future<bool> setDailyGoal(int minutes) async {
    if (minutes < 1 || minutes > 1440) return false;
    dailyGoalMinutes.value = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyGoal, minutes);
    return true;
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
