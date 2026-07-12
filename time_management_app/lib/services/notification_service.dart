import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  static const _pomodoroChannelId   = 'pomodoro_timer';
  static const _pomodoroChannelName = 'Pomodoro Timer';
  static const _scheduledId         = 1001;
  static const _instantId           = 1002;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initTimezones() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }

  Future<NotificationService> init() async {
    try {
      await initTimezones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings);

      const channel = AndroidNotificationChannel(
        _pomodoroChannelId,
        _pomodoroChannelName,
        description: 'Thông báo khi phiên Pomodoro kết thúc',
        importance: Importance.high,
        playSound: true,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Bỏ qua khi chạy unit test / platform chưa sẵn sàng
    }

    return this;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _pomodoroChannelId,
          _pomodoroChannelName,
          channelDescription: 'Thông báo khi phiên Pomodoro kết thúc',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      );

  Future<void> schedulePomodoroEnd({
    required DateTime endsAt,
    required String sessionLabel,
    String taskTitle = '',
  }) async {
    try {
      await cancelPomodoroEnd();

      final body = taskTitle.isNotEmpty
          ? '$sessionLabel — $taskTitle'
          : sessionLabel;

      await _plugin.zonedSchedule(
        _scheduledId,
        'TimeWise — Hết giờ!',
        body,
        tz.TZDateTime.from(endsAt, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {}
  }

  Future<void> showSessionComplete({
    required String sessionLabel,
    String taskTitle = '',
  }) async {
    try {
      final body = taskTitle.isNotEmpty
          ? '$sessionLabel — $taskTitle'
          : sessionLabel;

      await _plugin.show(
        _instantId,
        'TimeWise — Hết giờ!',
        body,
        _details,
      );
    } catch (_) {}
  }

  Future<void> cancelPomodoroEnd() async {
    try {
      await _plugin.cancel(_scheduledId);
    } catch (_) {}
  }
}
