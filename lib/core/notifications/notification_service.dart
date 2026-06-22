import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:developer';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      log('NotificationService init failed (notifications disabled): $e');
      _initialized = false;
    }
  }

  Future<bool> requestPermission() async {
    if (!_initialized) return false;

    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      log('Notification permission request failed: $e');
      return false;
    }
  }

  Future<void> scheduleUnlockReminder({
    required int id,
    required String capsuleTitle,
    required DateTime unlockDate,
  }) async {
    if (!_initialized) return;

    try {
      final reminderDate = unlockDate.subtract(const Duration(days: 1));
      if (reminderDate.isBefore(DateTime.now())) return;

      final tzDateTime = tz.TZDateTime.from(reminderDate, tz.local);

      await _plugin.zonedSchedule(
        id,
        'Cápsula próximamente disponible',
        '"$capsuleTitle" se desbloquea mañana',
        tzDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'capsule_reminders',
            'Recordatorios de cápsulas',
            channelDescription: 'Notificaciones cuando una cápsula está por desbloquearse',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      log('Failed to schedule notification: $e');
    }
  }

  Future<void> showUnlockedNotification({
    required int id,
    required String capsuleTitle,
  }) async {
    if (!_initialized) return;

    try {
      await _plugin.show(
        id,
        'Cápsula desbloqueada',
        '"$capsuleTitle" ya está disponible',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'capsule_unlocked',
            'Cápsulas desbloqueadas',
            channelDescription: 'Notificaciones cuando una cápsula se desbloquea',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      log('Failed to show notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id);
    } catch (e) {
      log('Failed to cancel notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      log('Failed to cancel notifications: $e');
    }
  }
}
