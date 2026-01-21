import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';

class GoogleDriveSettingCard extends StatelessWidget {
  final bool isConnected;
  final DateTime? lastSyncDate;
  final String? userEmail;
  final Function(bool) onToggle;

  const GoogleDriveSettingCard({
    super.key,
    required this.isConnected,
    this.lastSyncDate,
    this.userEmail,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: (isConnected ? AppTheme.successGreen : AppTheme.errorRed).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
              size: AppTheme.iconSizeLarge,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected && userEmail != null ? userEmail! : 'Google Drive',
                  style: AppTheme.cardTitle.copyWith(
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  isConnected 
                      ? (lastSyncDate != null 
                          ? 'Dernière sync: ${DateFormat('dd/MM/yyyy à HH:mm').format(lastSyncDate!)}'
                          : 'Synchronisation activée')
                      : 'Activer la synchronisation cloud',
                  style: AppTheme.cardSubtitle.copyWith(
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isConnected,
            onChanged: onToggle,
            activeColor: AppTheme.successGreen,
            inactiveThumbColor: AppTheme.errorRed,
          ),
        ],
      ),
    );
  }
}