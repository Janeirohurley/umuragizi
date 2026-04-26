import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../services/export_import_service.dart';
import '../../services/google_drive_service.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/google_drive_setting_card.dart';
import '../../l10n/app_localizations.dart';

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
  bool _isSyncInProgress = false;
  DateTime? _lastSyncDate;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkGoogleDriveConnection();
  }

  Future<void> _checkGoogleDriveConnection() async {
    final isConnected = await GoogleDriveService.isSyncEnabled;
    final lastSync = await GoogleDriveService.getLastSyncDate();
    final email = await GoogleDriveService.getUserEmail();
    final syncInProgress = await GoogleDriveService.isSyncInProgress();
    setState(() {
      _isGoogleDriveConnected = isConnected;
      _lastSyncDate = lastSync;
      _userEmail = email;
      _isSyncInProgress = syncInProgress;
    });
  }

  void _showLanguageDialog() {
    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    _showSelectionBottomSheet(
      title: l10n.language,
      icon: Icons.language_outlined,
      children: [
        _buildLanguageOption(context, settingsProvider, l10n.languagern, const Locale('rn'), '🇧🇮'),
        _buildLanguageOption(context, settingsProvider, l10n.languagefr, const Locale('fr'), '🇫🇷'),
        _buildLanguageOption(context, settingsProvider, l10n.languageen, const Locale('en'), '🇺🇸'),
        _buildLanguageOption(context, settingsProvider, l10n.languagesw, const Locale('sw'), '🇹🇿'),
      ],
    );
  }

  Widget _buildLanguageOption(BuildContext context, SettingsProvider provider, String name, Locale locale, String flag) {
    final isSelected = provider.locale.languageCode == locale.languageCode;
    return CustomCard(
      onTap: () {
        provider.setLocale(locale);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(child: Text(name, style: AppTheme.listItemTitle)),
          if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryPurple),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    _showSelectionBottomSheet(
      title: l10n.currency,
      icon: Icons.monetization_on_outlined,
      children: [
        _buildCurrencyOption(
            context, settingsProvider, l10n.currencybif, 'BIF'),
        _buildCurrencyOption(
            context, settingsProvider, l10n.currencyusd, 'USD'),
        _buildCurrencyOption(
            context, settingsProvider, l10n.currencykes, 'KES'),
        _buildCurrencyOption(
            context, settingsProvider, l10n.currencyeur, 'EUR'),
      ],
    );
  }

  Widget _buildCurrencyOption(BuildContext context, SettingsProvider provider, String name, String code) {
    final isSelected = provider.currency == code;
    return CustomCard(
      onTap: () {
        provider.setCurrency(code);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Container(
             width: 48,
             alignment: Alignment.center,
             child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(child: Text(name, style: AppTheme.listItemTitle)),
          if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryPurple),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    final themeProvider = context.read<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;
    _showSelectionBottomSheet(
      title: l10n.theme,
      icon: Icons.palette_outlined,
      children: [
        _buildThemeOption(context, themeProvider, l10n.themeLight, Icons.light_mode_outlined, false),
        _buildThemeOption(context, themeProvider, l10n.themeDark, Icons.dark_mode_outlined, true),
      ],
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeProvider provider,
      String name, IconData icon, bool isDark) {
    final isSelected = provider.isDarkMode == isDark;
    return CustomCard(
      onTap: () {
        if (provider.isDarkMode != isDark) provider.toggleTheme();
        Navigator.pop(context);
      },
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingSmall),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkPurple : AppTheme.lightPurple),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(icon, color: AppTheme.primaryPurple, size: AppTheme.iconSizeLarge),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(child: Text(name, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)))),
        if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryPurple),
      ]),
    );
  }

  void _showSelectionBottomSheet({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingXLarge, 0,
            AppTheme.spacingXLarge, AppTheme.spacingXXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppTheme.spacingMedium),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLightOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                decoration: const BoxDecoration(
                    color: AppTheme.lightPurple, shape: BoxShape.circle),
                child: Icon(icon,
                    color: AppTheme.primaryPurple,
                    size: AppTheme.iconSizeLarge),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Text(title,
                  style: AppTheme.bottomSheetTitle
                      .copyWith(color: AppTheme.textPrimaryOf(context))),
            ]),
            const SizedBox(height: AppTheme.spacingXLarge),
            ...children.map((child) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppTheme.spacingSmall),
                  child: child,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await ExportImportService.saveExportToFile();
      await Share.shareXFiles([XFile(file.path)], text: 'Export umuragizi');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess),
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
            content: Text('${l10n.exportError}: $e'),
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
      final l10n = AppLocalizations.of(context)!;
      try {
        final file = File(result.files.single.path!);
        await ExportImportService.importFromFile(file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.importSuccess),
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
              content: Text('${l10n.importError}: $e'),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      await GoogleDriveService.disconnect();
      await _checkGoogleDriveConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driveDisconnected),
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
            content: Text('${l10n.driveDisconnected}: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    }
  }

  Future<void> _connectGoogleDrive() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await GoogleDriveService.authenticate();
      if (success) {
        await GoogleDriveService.setSyncEnabled(true);
        await _checkGoogleDriveConnection();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driveConnected),
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
            content: Text('${l10n.driveConnected}: $e'),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      final isConnected = await GoogleDriveService.isSyncEnabled;
      if (!isConnected) {
        throw Exception('Google Drive non connecté');
      }
      final success = await GoogleDriveService.syncData();
      if (success) {
        await _checkGoogleDriveConnection();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.driveBackupSuccess : l10n.driveBackupError),
            backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.driveBackupError}: $e'),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await GoogleDriveService.restoreData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.driveRestoreSuccess : l10n.driveNoBackup),
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
            content: Text('${l10n.driveRestoreSuccess}: $e'),
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
    final l10n = AppLocalizations.of(context)!;
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
              Text(
                l10n.appDescription,
                textAlign: TextAlign.center,
                style: AppTheme.bodyTextSecondary,
              ),
              const SizedBox(height: AppTheme.spacingXXLarge),
              PrimaryButton(
                text: l10n.close,
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
    final settingsProvider = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
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
          l10n.settings,
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
            l10n.dataManagement,
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.upload_file,
            iconColor: AppTheme.primaryPurple,
            title: l10n.exportData,
            subtitle: l10n.exportDataSubtitle,
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
            title: l10n.importData,
            subtitle: l10n.importDataSubtitle,
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
            l10n.synchronization,
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          GoogleDriveSettingCard(
            isConnected: _isGoogleDriveConnected,
            lastSyncDate: _lastSyncDate,
            userEmail: _userEmail,
            onToggle: _toggleGoogleDrive,
          ),
          if (_isGoogleDriveConnected) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            _buildSettingCard(
              icon: Icons.cloud_upload,
              iconColor: AppTheme.primaryPurple,
              title: l10n.backupDrive,
              subtitle: l10n.backupDriveSubtitle,
              onTap: (_isBackingUp || _isSyncInProgress) ? null : _backupToGoogleDrive,
              trailing: (_isBackingUp || _isSyncInProgress)
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
              title: l10n.restoreDrive,
              subtitle: l10n.restoreDriveSubtitle,
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
            l10n.preferences,
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.language_outlined,
            iconColor: AppTheme.primaryPurple,
            title: l10n.language,
            subtitle: settingsProvider.locale.languageCode.toUpperCase(),
            onTap: _showLanguageDialog,
            trailing: Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.monetization_on_outlined,
            iconColor: AppTheme.infoBlue,
            title: l10n.currency,
            subtitle: '${settingsProvider.currency} (${settingsProvider.currencySymbol})',
            onTap: _showCurrencyDialog,
            trailing: Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),
          Text(
            l10n.appearance,
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.palette_outlined,
            iconColor: AppTheme.accentOrange,
            title: l10n.theme,
            subtitle: l10n.themeSubtitle,
            onTap: _showThemeDialog,
            trailing: Icon(Icons.chevron_right, color: AppTheme.textLightOf(context)),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),
          Text(
            l10n.application,
            style: AppTheme.sectionTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSettingCard(
            icon: Icons.info_outline,
            iconColor: AppTheme.primaryGreen,
            title: l10n.about,
            subtitle: l10n.aboutSubtitle,
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
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
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
