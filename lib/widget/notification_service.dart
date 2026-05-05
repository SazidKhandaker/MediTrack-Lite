import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  static final FlutterLocalNotificationsPlugin _notification =
  FlutterLocalNotificationsPlugin();

  /// 🔥 INIT
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notification.initialize(settings);

    /// 🔥 CHANNEL
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'med_channel',
      'Medicine Reminder',
      description: 'Reminder for medicines',
      importance: Importance.max,
    );

    await _notification
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 🔥 TEST NOTIFICATION
  static Future<void> showTestNotification() async {
    await _notification.show(
      0,
      "TEST 🔔",
      "Notification working",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "test_channel",
          "Test",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// 🔥 MAIN FUNCTION
  static Future<void> scheduleMedicine({
    required String name,
    required int hour,
    required int minute,
    required int beforeMin,
    required String date, // 🔥 NEW
  }) async {

    final selectedDate = DateTime.parse(date);

    final scheduledTime = tz.TZDateTime(
      tz.local,
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      hour,
      minute,
    );

    final reminderTime =
    scheduledTime.subtract(Duration(minutes: beforeMin));

    print("NOW: ${DateTime.now()}");
    print("SCHEDULED: $scheduledTime");
    print("REMINDER: $reminderTime");

    // ❌ past হলে schedule করবে না
    if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    /// 🔥 MAIN SCHEDULE
    await _notification.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "💊 Medicine Time",
      "⏰ $name নেওয়ার সময় হয়েছে",
      reminderTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "med_channel",
          "Medicine Reminder",
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    /// 🔥 FALLBACK (optional রাখতে পারো)
    final diff = reminderTime.difference(DateTime.now());

    if (diff.inSeconds > 0) {
      Future.delayed(diff, () async {
        await _notification.show(
          999,
          "💊 Medicine Reminder",
          "⏰ $name নেওয়ার সময় হয়েছে",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "med_channel",
              "Medicine Reminder",
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      });
    }
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

  /// 🔥 CANCEL ALL
  static Future<void> cancelAll() async {
    await _notification.cancelAll();
  }
  static Future<void> scheduleAllFromDB() async {
    final user = FirebaseAuth.instance.currentUser;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .get();

    int id = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['time'] == null || data['date'] == null) {
        print("⚠️ Skipped invalid data: $data");
        continue;
      }
      final time = _parseTime(data['time']);

      await NotificationService.scheduleMedicine(
        name: data['name'],
        hour: time['hour']!,
        minute: time['minute']!,
        beforeMin: 0, // 🔥 or 5 (5 min before)
          date: data['date']
      );
    }
  }
  static Map<String, int> _parseTime(String time) {
    final parts = time.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].split(" ")[0]);

    if (time.contains("PM") && hour != 12) hour += 12;
    if (time.contains("AM") && hour == 12) hour = 0;

    return {
      "hour": hour,
      "minute": minute,
    };
  }
}