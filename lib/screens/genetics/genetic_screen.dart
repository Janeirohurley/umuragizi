import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/animal_provider.dart';
import '../../providers/genetic_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import '../animal/animal_detail_screen.dart';

class GeneticScreen extends StatefulWidget {
  const GeneticScreen({super.key});

  @override
  State<GeneticScreen> createState() => _GeneticScreenState();
}

class _GeneticScreenState extends State<GeneticScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeneticProvider>().chargerGeneticInfos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final geneticProvider = context.watch<GeneticProvider>();
    final animals = [...context.watch<AnimalProvider>().animaux];

    animals.sort((first, second) {
      final firstInfo = geneticProvider.getGeneticInfo(first.id);
      final secondInfo = geneticProvider.getGeneticInfo(second.id);
      if (firstInfo != null && secondInfo != null) {
        return secondInfo.ebv.compareTo(firstInfo.ebv);
      }
      if (firstInfo != null) {
        return -1;
      }
      if (secondInfo != null) {
        return 1;
      }
      return first.nom.toLowerCase().compareTo(second.nom.toLowerCase());
    });

    if (animals.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColorOf(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.genetics,
            style: AppTheme.pageTitle.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.science_outlined,
                size: 64,
                color: AppTheme.primaryPurple,
              ),
              SizedBox(height: AppTheme.spacingLarge),
              Text(
                l10n.noAnimal,
                style: AppTheme.sectionTitle.copyWith(
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.genetics,
          style: AppTheme.pageTitle.copyWith(
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: geneticProvider.isBulkUpdating
                ? null
                : () => context.read<GeneticProvider>().recalculateAll(),
            icon: geneticProvider.isBulkUpdating
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryPurple,
                      ),
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: AppTheme.primaryPurple,
                  ),
            tooltip: l10n.recalculate,
          ),
        ],
      ),
      body: Column(
        children: [
          if (geneticProvider.isBulkUpdating)
            const LinearProgressIndicator(
              color: AppTheme.primaryPurple,
            ),
          if (geneticProvider.errorMessage != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppTheme.spacingXLarge,
                AppTheme.spacingMedium,
                AppTheme.spacingXLarge,
                0,
              ),
              child: CustomCard(
                backgroundColor: AppTheme.errorRed.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.errorRed,
                      size: AppTheme.iconSizeLarge,
                    ),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Text(
                        geneticProvider.errorMessage!,
                        style: AppTheme.bodyTextSecondary.copyWith(
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: PetRefreshIndicator(
              onRefresh: () async {
                context.read<AnimalProvider>().chargerAnimaux();
                await context.read<GeneticProvider>().chargerGeneticInfos();
              },
              child: geneticProvider.isLoading && geneticProvider.geneticInfos.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 240),
                        Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(AppTheme.spacingXLarge),
                      itemCount: animals.length,
                      itemBuilder: (context, index) {
                        final animal = animals[index];
                        final info = geneticProvider.getGeneticInfo(animal.id);
                        final isUpdating = geneticProvider.isUpdatingAnimal(animal.id);

                        return Padding(
                          padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
                          child: CustomCard(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnimalDetailScreen(
                                  animalId: animal.id,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(AppTheme.spacingMedium),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                      ),
                                      child: Icon(
                                        Icons.pets,
                                        color: AppTheme.primaryPurple,
                                        size: AppTheme.iconSizeLarge,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spacingMedium),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            animal.nom,
                                            style: AppTheme.listItemTitle.copyWith(
                                              color: AppTheme.textPrimaryOf(context),
                                            ),
                                          ),
                                          SizedBox(height: AppTheme.spacingXSmall),
                                          Text(
                                            '${animal.espece} • ${animal.race}',
                                            style: AppTheme.listItemSubtitle.copyWith(
                                              color: AppTheme.textSecondaryOf(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: isUpdating
                                          ? null
                                          : () => context
                                              .read<GeneticProvider>()
                                              .updateForAnimal(animal),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryPurple,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        minimumSize: const Size(0, 32),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        textStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSmall,
                                          ),
                                        ),
                                      ),
                                      child: isUpdating
                                          ? SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.8,
                                                valueColor: const AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              info == null
                                                  ? l10n.calculate
                                                  : l10n.recalculate,
                                            ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.spacingMedium),
                                Wrap(
                                  spacing: AppTheme.spacingSmall,
                                  runSpacing: AppTheme.spacingSmall,
                                  children: [
                                    _MetricChip(
                                      label: l10n.ebv,
                                      value: info == null
                                          ? l10n.notCalculated
                                          : _formatSigned(info.ebv),
                                      color: info == null
                                          ? AppTheme.primaryPurple
                                          : _ebvColor(info.ebv),
                                    ),
                                    _MetricChip(
                                      label: l10n.inbreedingCoefficient,
                                      value: info == null
                                          ? l10n.notCalculated
                                          : '${(info.inbreedingCoefficient * 100).toStringAsFixed(2)}%',
                                      color: info == null
                                          ? AppTheme.primaryPurple
                                          : _inbreedingColor(info.inbreedingCoefficient),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.spacingMedium),
                                Text(
                                  '${l10n.lastCalculated}: ${info == null ? l10n.notCalculated : DateFormat('dd MMM yyyy HH:mm', settings.intlLocale).format(info.lastCalculatedAt)}',
                                  style: AppTheme.bodyTextSecondary.copyWith(
                                    color: AppTheme.textSecondaryOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSigned(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}';
  }

  Color _ebvColor(double value) {
    return value >= 0 ? AppTheme.successGreen : AppTheme.errorRed;
  }

  Color _inbreedingColor(double value) {
    if (value >= 0.125) {
      return AppTheme.errorRed;
    }
    if (value >= 0.0625) {
      return AppTheme.warningOrange;
    }
    return AppTheme.successGreen;
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.tagText.copyWith(color: color),
          ),
          SizedBox(height: AppTheme.spacingXSmall),
          Text(
            value,
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.textPrimaryOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
