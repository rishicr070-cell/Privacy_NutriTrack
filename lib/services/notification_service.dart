import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/storage_helper.dart';

/// Service for managing local notifications, specifically water reminders
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // The app will already be opened when notification is tapped
    // Additional navigation logic can be added here if needed
  }

  /// Request notification permissions (especially important for iOS and Android 13+)
  static Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }

    return true; // For other platforms, assume granted
  }

  /// Schedule water reminder notifications
  static Future<void> scheduleWaterReminders() async {
    try {
      // Cancel any existing reminders first
      await cancelWaterReminders();

      // Get the reminder interval from storage (default: 240 minutes = 4 hours)
      final intervalMinutes = await StorageHelper.getWaterReminderInterval();

      debugPrint('Scheduling water reminders every $intervalMinutes minutes');

      // Schedule multiple notifications throughout the day
      // We'll schedule 6 notifications (one every 4 hours from 8 AM to 8 PM)
      final now = DateTime.now();
      final startHour = 8; // 8 AM
      final endHour = 20; // 8 PM

      int notificationId = 1000; // Start ID for water reminders

      for (
        int hour = startHour;
        hour <= endHour;
        hour += (intervalMinutes ~/ 60)
      ) {
        final scheduledTime = DateTime(now.year, now.month, now.day, hour, 0);

        // If the time has passed today, schedule for tomorrow
        final targetTime = scheduledTime.isBefore(now)
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime;

        await _scheduleNotification(
          id: notificationId++,
          title: '💧 Hydration Reminder',
          body: 'Time to drink some water! Stay hydrated 🌊',
          scheduledTime: targetTime,
          intervalMinutes: intervalMinutes,
        );
      }

      debugPrint('✅ Water reminders scheduled successfully');
    } catch (e) {
      debugPrint('❌ Error scheduling water reminders: $e');
    }
  }

  /// Schedule a single notification with repeat
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required int intervalMinutes,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'water_reminders',
      'Water Reminders',
      channelDescription: 'Notifications to remind you to drink water',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert to timezone-aware datetime
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Schedule the notification to repeat daily
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // Repeat daily at same time
    );
  }

  /// Cancel all water reminder notifications
  static Future<void> cancelWaterReminders() async {
    try {
      // Cancel notifications with IDs 1000-1010 (water reminder range)
      for (int i = 1000; i <= 1010; i++) {
        await _notifications.cancel(i);
      }
      debugPrint('✅ Water reminders cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling water reminders: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  /// Show an immediate notification (for testing)
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'water_reminders',
      'Water Reminders',
      channelDescription: 'Notifications to remind you to drink water',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(0, title, body, notificationDetails);
  }
}
