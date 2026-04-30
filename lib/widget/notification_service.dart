import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
  FlutterLocalNotificationsPlugin();

  /// 🔥 INIT
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    await _notification.initialize(settings);
  }

  /// 🔥 MAIN FUNCTION
  static Future<void> scheduleMedicine({
    required String name,
    required int hour,
    required int minute,
    required int beforeMin,
  }) async {

    final scheduledTime = _nextInstance(hour, minute);

    final reminderTime =
    scheduledTime.subtract(Duration(minutes: beforeMin));

    await _notification.zonedSchedule(
      (DateTime.now().millisecondsSinceEpoch % 100000),
      "💊 Medicine Reminder",
      "$name নিতে হবে $beforeMin মিনিট পরে",
      reminderTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "med_channel",
          "Medicine Reminder",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("Reminder scheduled at: $reminderTime");
  } // ✅ 🔥 IMPORTANT (function close)

  /// 🔥 TIME CALCULATION
  static tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// 🔥 CANCEL ALL
  static Future<void> cancelAll() async {
    await _notification.cancelAll();
  }
}