import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';

class BackgroundTaskService {
  static Timer? _timer;
  static bool _isRunning = false;

  static void startPeriodicCheck() {
    // Vérifier s'il y a des rappels actifs avant de démarrer
    final rappelsActifs = DatabaseService.getRappelsActifs();
    if (rappelsActifs.isEmpty) {
      debugPrint('Aucun rappel actif - service de background non démarré');
      return;
    }

    if (_isRunning) return;
    
    _isRunning = true;
    debugPrint('Démarrage du service de background - ${rappelsActifs.length} rappels actifs');
    
    // Check immediately
    _checkReminders();
    
    // Then check every 15 minutes
    _timer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _checkReminders();
    });
  }

  static void _checkReminders() {
    try {
      // Vérifier s'il y a encore des rappels actifs
      final rappelsActifs = DatabaseService.getRappelsActifs();
      if (rappelsActifs.isEmpty) {
        debugPrint('Plus de rappels actifs - arrêt du service de background');
        stopPeriodicCheck();
        return;
      }
      
      NotificationService.checkAndNotifyDueReminders();
    } catch (e) {
      // Ignore errors to prevent app crashes
      debugPrint('Background reminder check failed: $e');
    }
  }

  static void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('Service de background arrêté');
  }

  static void resumeFromBackground() {
    // Vérifier s'il y a des rappels actifs avant de vérifier
    final rappelsActifs = DatabaseService.getRappelsActifs();
    if (rappelsActifs.isNotEmpty) {
      _checkReminders();
    }
  }

  static void onReminderAdded() {
    // Démarrer le service quand un rappel est ajouté
    if (!_isRunning) {
      startPeriodicCheck();
    }
  }

  static void onReminderCompleted() {
    // Vérifier s'il faut arrêter le service
    final rappelsActifs = DatabaseService.getRappelsActifs();
    if (rappelsActifs.isEmpty && _isRunning) {
      stopPeriodicCheck();
    }
  }
}