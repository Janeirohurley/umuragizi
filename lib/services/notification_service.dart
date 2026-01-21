import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/rappel.dart';
import '../services/database_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static bool _initializationFailed = false;

  static Future<void> init() async {
    if (_isInitialized || _initializationFailed) return;
    
    try {
      const androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      
      _isInitialized = true;
      debugPrint('Service de notifications initialisé avec succès');
    } catch (e) {
      _initializationFailed = true;
      debugPrint('Échec de l\'initialisation des notifications: $e');
    }
  }

  static void _onNotificationTap(NotificationResponse response) async {
    if (response.payload != null) {
      await _playAlarmSound();
    }
  }

  static Future<void> _playAlarmSound() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      HapticFeedback.vibrate();
    } catch (e) {
      // Ignore if sound/vibration fails
    }
  }

  static Future<void> scheduleReminderNotification(Rappel rappel) async {
    if (_initializationFailed) return;
    if (!_isInitialized) await init();
    if (_initializationFailed) return;
    
    // Only show notification if the reminder date has passed
    if (rappel.dateRappel.isBefore(DateTime.now())) {
      await showImmediateNotification(rappel);
    }
  }

  static Future<void> cancelReminderNotification(String rappelId) async {
    if (_initializationFailed || !_isInitialized) return;
    
    try {
      await _notifications.cancel(rappelId.hashCode);
      
      // Cancel recurring notifications
      for (int i = 1; i <= 10; i++) {
        await _notifications.cancel(rappelId.hashCode + i);
      }
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }

  static Future<void> markReminderComplete(String rappelId) async {
    await cancelReminderNotification(rappelId);
    await DatabaseService.marquerRappelComplete(rappelId);
  }

  static Future<void> showImmediateNotification(Rappel rappel) async {
    if (_initializationFailed) return;
    if (!_isInitialized) await init();
    if (_initializationFailed) return;
    
    try {
      const androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Rappels SmartFarm',
        channelDescription: 'Notifications pour les rappels d\'animaux',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        rappel.id.hashCode,
        'Rappel: ${rappel.titre}',
        rappel.description,
        details,
        payload: rappel.id,
      );

      await _playAlarmSound();
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  static Future<void> checkAndNotifyDueReminders() async {
    if (_initializationFailed) return;
    
    final rappels = DatabaseService.getRappelsActifs();
    if (rappels.isEmpty) return;
    
    if (!_isInitialized) await init();
    if (_initializationFailed) return;
    
    final now = DateTime.now();
    
    for (final rappel in rappels) {
      if (!rappel.estComplete && rappel.dateRappel.isBefore(now)) {
        await showImmediateNotification(rappel);
      }
    }
  }
}