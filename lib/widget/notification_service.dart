import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
  FlutterLocalNotificationsPlugin();

  /// 🔥 INIT (app start এ call করবে)
  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    await _notification.initialize(settings);
  }

  /// 🔥 MAIN FUNCTION (medicine reminder)
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
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "💊 Medicine Reminder",
      "$name নিতে হবে ${beforeMin} মিনিট পরে",
      reminderTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "med_channel",
          "Medicine Reminder",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 🔁 daily repeat
    );
  }

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

  /// 🔥 ALL NOTIFICATION CANCEL (optional)
  static Future<void> cancelAll() async {
    await _notification.cancelAll();
  }
}