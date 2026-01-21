import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SyncNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  static Future<void> showSyncStarted() async {
    await initialize();
    await _notifications.show(
      1,
      'Synchronisation en cours',
      'Sauvegarde de vos données sur Google Drive...',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sync_channel',
          'Synchronisation',
          channelDescription: 'Notifications de synchronisation Google Drive',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
        ),
      ),
    );
  }

  static Future<void> showSyncSuccess() async {
    await _notifications.cancel(1);
    await _notifications.show(
      2,
      'Synchronisation réussie',
      'Vos données ont été sauvegardées sur Google Drive',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sync_channel',
          'Synchronisation',
          channelDescription: 'Notifications de synchronisation Google Drive',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  static Future<void> showSyncError() async {
    await _notifications.cancel(1);
    await _notifications.show(
      3,
      'Erreur de synchronisation',
      'Synchronisation en attente - sera reprise automatiquement',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sync_channel',
          'Synchronisation',
          channelDescription: 'Notifications de synchronisation Google Drive',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  static Future<void> showSyncPending() async {
    await _notifications.show(
      4,
      'Synchronisation en attente',
      'Vos données seront synchronisées dès que la connexion sera disponible',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sync_channel',
          'Synchronisation',
          channelDescription: 'Notifications de synchronisation Google Drive',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
    );
  }
}