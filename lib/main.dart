import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';
import 'services/background_task_service.dart';
import 'services/google_drive_service.dart';
import 'services/background_sync_service.dart';
import 'providers/animal_provider.dart';
import 'providers/rappel_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/pin_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await DatabaseService.init();
  await GoogleDriveService.initialize();
  await BackgroundSyncService.initialize();
  
  // Programmer la synchronisation périodique
  if (await GoogleDriveService.isSyncEnabled) {
    await BackgroundSyncService.schedulePeriodicSync();
  }
  
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    BackgroundTaskService.startPeriodicCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundTaskService.stopPeriodicCheck();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BackgroundTaskService.resumeFromBackground();
      // Vérifier et exécuter la sync en attente quand l'app revient
      _checkAndExecutePendingSync();
    }
  }

  Future<void> _checkAndExecutePendingSync() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPending = prefs.getBool('google_drive_pending_sync') ?? false;
    
    if (hasPending && await GoogleDriveService.isSyncEnabled) {
      // Exécuter la sync en attente dans l'app principale
      GoogleDriveService.checkPendingSync();
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isNotEmpty) {
        _handleConnectionChange(results.first);
      }
    } catch (e) {
      // Ignorer les erreurs de connectivité
    }
  }

  void _handleConnectionChange(ConnectivityResult result) {
    // Vérifier sync en attente quand connexion revient
    if (result != ConnectivityResult.none) {
      GoogleDriveService.checkPendingSync();
      // Programmer une tâche de sync en arrière-plan
      BackgroundSyncService.schedulePendingSync();
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isNotEmpty) {
      _handleConnectionChange(results.first);
    }
  }

  Future<bool> _hasPinConfigured() async {
    final box = await Hive.openBox('pin_settings');
    return box.get('user_pin') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AnimalProvider()),
        ChangeNotifierProvider(create: (_) => RappelProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'umuragizi',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: FutureBuilder<bool>(
              future: _hasPinConfigured(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _SplashScreen();
                }
                final hasPin = snapshot.data ?? false;
                return PinScreen(isSetup: !hasPin);
              },
            ),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'umuragizi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}