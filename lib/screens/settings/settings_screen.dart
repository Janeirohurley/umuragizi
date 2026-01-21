import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../services/export_import_service.dart';
import '../../services/google_drive_service.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/google_drive_setting_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isGoogleDriveConnected = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  DateTime? _lastSyncDate;

  @override
  void initState() {
    super.initState();
    _checkGoogleDriveConnection();
  }

  Future<void> _checkGoogleDriveConnection() async {
    final isConnected = await GoogleDriveService.isSyncEnabled;
    final lastSync = await GoogleDriveService.getLastSyncDate();
    setState(() {
      _isGoogleDriveConnected = isConnected;
      _lastSyncDate = lastSync;
    });
  }

  void _showThemeDialog() {
    final themeProvider = context.read<ThemeProvider>();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXXLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: const BoxDecoration(
                  color: AppTheme.lightPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.palette_outlined, size: AppTheme.iconSizeXLarge, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              Text(
                'Thème',
                style: AppTheme.pageTitle.copyWith(
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXXLarge),
              SwitchListTile(
                title: const Text('Mode sombre', style: AppTheme.listItemTitle),
                subtitle: const Text('Activer le thème sombre', style: AppTheme.listItemSubtitle),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  Navigator.pop(context);
                },
                activeThumbColor: AppTheme.primaryPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final file = await ExportImportService.saveExportToFile();
      await Share.shareXFiles([XFile(file.path)], text: 'Export umuragizi');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Données exportées avec succès'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isImporting = true);
      try {
        final file = File(result.files.single.path!);
        await ExportImportService.importFromFile(file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Données importées avec succès'),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'import: $e'),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _toggleGoogleDrive(bool value) async {
    if (value) {
      await _connectGoogleDrive();
    } else {
      await _disconnectGoogleDrive();
    }
  }

  Future<void> _disconnectGoogleDrive() async {
    try {
      await GoogleDriveService.disconnect();
      await _checkGoogleDriveConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Déconnecté de Google Drive'),
            backgroundColor: AppTheme.infoBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de déconnexion: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    }
  }

  Future<void> _connectGoogleDrive() async {
    try {
      final success = await GoogleDriveService.authenticate();
      if (success) {
        await GoogleDriveService.setSyncEnabled(true);
        await _checkGoogleDriveConnection();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Connecté à Google Drive'),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
            ),
          );
        }
      } else {
        throw Exception('Échec de l\'authentification');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    }
  }

  Future<void> _backupToGoogleDrive() async {
    setState(() => _isBackingUp = true);
    try {
      // Vérifier d'abord la connexion
      final isConnected = await GoogleDriveService.isSyncEnabled;
      if (!isConnected) {
        throw Exception('Google Drive non connecté');
      }
      
      final success = await GoogleDriveService.syncData();
      if (success) {
        await _checkGoogleDriveConnection(); // Mettre à jour la date de sync
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Sauvegarde Google Drive réussie' : 'Erreur de sauvegarde'),
            backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    } catch (e) {
      print('Erreur backup: $e'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de sauvegarde: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromGoogleDrive() async {
    setState(() => _isRestoring = true);
    try {
      final success = await GoogleDriveService.restoreData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Restauration Google Drive réussie' : 'Aucune sauvegarde trouvée'),
            backgroundColor: success ? AppTheme.successGreen : AppTheme.warningOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de restauration: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXXLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: const BoxDecoration(
                  color: AppTheme.lightPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.agriculture, size: AppTheme.iconSizeXLarge, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              Text(
                'umuragizi',
                style: AppTheme.sectionTitle.copyWith(
                  fontSize: 24,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              const Text(
                'Version 1.0.0',
                style: AppTheme.bodyTextSecondary,
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              const Text(
                'Application de gestion d\'élevage',
                textAlign: TextAlign.center,
                style: AppTheme.bodyTextSecondary,
              ),
              const SizedBox(height: AppTheme.spacingXXLarge),
              PrimaryButton(
                text: 'Fermer',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: AppTheme.cardBackgroundOf(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.softShadow,
            ),
            child: Icon(Icons.arrow_back, color: AppTheme.textPrimaryOf(context), size: AppTheme.iconSizeMedium),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Paramètres',
          style: AppTheme.pageTitle.copyWith(
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        children: [
          Text(
            'Données',
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.upload_file,
            iconColor: AppTheme.primaryPurple,
            title: 'Exporter les données',
            subtitle: 'Sauvegarder toutes vos données',
            onTap: _isExporting ? null : _exportData,
            trailing: _isExporting
                ? const SizedBox(
                    width: AppTheme.iconSizeMedium,
                    height: AppTheme.iconSizeMedium,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.download,
            iconColor: AppTheme.infoBlue,
            title: 'Importer les données',
            subtitle: 'Restaurer depuis un fichier',
            onTap: _isImporting ? null : _importData,
            trailing: _isImporting
                ? const SizedBox(
                    width: AppTheme.iconSizeMedium,
                    height: AppTheme.iconSizeMedium,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),
          Text(
            'Google Drive',
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          GoogleDriveSettingCard(
            isConnected: _isGoogleDriveConnected,
            lastSyncDate: _lastSyncDate,
            onToggle: _toggleGoogleDrive,
          ),
          if (_isGoogleDriveConnected) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            _buildSettingCard(
              icon: Icons.cloud_upload,
              iconColor: AppTheme.primaryPurple,
              title: 'Sauvegarder sur Drive',
              subtitle: 'Synchroniser vos données',
              onTap: _isBackingUp ? null : _backupToGoogleDrive,
              trailing: _isBackingUp
                  ? const SizedBox(
                      width: AppTheme.iconSizeMedium,
                      height: AppTheme.iconSizeMedium,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildSettingCard(
              icon: Icons.cloud_download,
              iconColor: AppTheme.infoBlue,
              title: 'Restaurer depuis Drive',
              subtitle: 'Récupérer vos données sauvegardées',
              onTap: _isRestoring ? null : _restoreFromGoogleDrive,
              trailing: _isRestoring
                  ? const SizedBox(
                      width: AppTheme.iconSizeMedium,
                      height: AppTheme.iconSizeMedium,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
            ),
          ],
          const SizedBox(height: AppTheme.spacingXXLarge),
          Text(
            'Apparence',
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.palette_outlined,
            iconColor: AppTheme.accentOrange,
            title: 'Thème',
            subtitle: 'Clair ou sombre',
            onTap: _showThemeDialog,
            trailing: Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),
          Text(
            'Application',
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.info_outline,
            iconColor: AppTheme.primaryGreen,
            title: 'À propos',
            subtitle: 'Version et informations',
            onTap: _showAboutDialog,
            trailing: Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Widget trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(icon, color: iconColor, size: AppTheme.iconSizeLarge),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.cardTitle.copyWith(
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Text(
                    subtitle,
                    style: AppTheme.cardSubtitle.copyWith(
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}