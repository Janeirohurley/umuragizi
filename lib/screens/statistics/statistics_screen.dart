import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/animal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _selectedAnimalId;

  void _showAnimalBottomSheet(AppLocalizations l10n) {
    final animaux = context.read<AnimalProvider>().animaux;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppTheme.spacingMedium),
            Container(
              width: AppTheme.spacingXXLarge,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLightOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              l10n.animals,
              style: AppTheme.bottomSheetTitle.copyWith(
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            ...animaux.map((animal) => ListTile(
              leading: Icon(
                Icons.pets,
                color: _selectedAnimalId == animal.id ? AppTheme.primaryPurple : AppTheme.textSecondaryOf(context),
              ),
              title: Text(
                animal.nom,
                style: TextStyle(
                  fontWeight: _selectedAnimalId == animal.id ? FontWeight.w600 : FontWeight.normal,
                  color: _selectedAnimalId == animal.id ? AppTheme.primaryPurple : AppTheme.textPrimaryOf(context),
                ),
              ),
              trailing: _selectedAnimalId == animal.id
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryPurple)
                  : null,
              onTap: () {
                setState(() => _selectedAnimalId = animal.id);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: AppTheme.spacingLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animaux = context.watch<AnimalProvider>().animaux;
    
    if (_selectedAnimalId == null && animaux.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedAnimalId = animaux.first.id);
        }
      });
    }
    
    final selectedAnimal = _selectedAnimalId != null && animaux.any((a) => a.id == _selectedAnimalId)
        ? animaux.firstWhere((a) => a.id == _selectedAnimalId)
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Stats',
          style: AppTheme.pageTitle.copyWith(
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        centerTitle: true,
      ),
      body: animaux.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.bar_chart, size: 64, color: AppTheme.primaryPurple),
                   SizedBox(height: 16),
                   Text(l10n.noData, style: AppTheme.sectionTitle),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppTheme.spacingXLarge),
              children: [
                GestureDetector(
                  onTap: () => _showAnimalBottomSheet(l10n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColorOf(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pets, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                        const SizedBox(width: AppTheme.spacingMedium),
                        Expanded(
                          child: Text(
                            _selectedAnimalId == null ? l10n.animals : (selectedAnimal?.nom ?? l10n.noData),
                            style: AppTheme.formInput.copyWith(
                              color: _selectedAnimalId == null ? AppTheme.textLightOf(context) : AppTheme.textPrimaryOf(context),
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: AppTheme.textLightOf(context)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                if (_selectedAnimalId != null) _buildStatistics(_selectedAnimalId!, l10n),
              ],
            ),
    );
  }

  Widget _buildStatistics(String animalId, AppLocalizations l10n) {
    final croissances = DatabaseService.getCroissancesParAnimal(animalId);
    final alimentations = DatabaseService.getAlimentationsParAnimal(animalId);
    final santes = DatabaseService.getSantesParAnimal(animalId);
    final settings = context.watch<SettingsProvider>();

    return Column(
      children: [
        if (croissances.isNotEmpty) ...[
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Poids (kg)',
                  style: AppTheme.cardTitle.copyWith(
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}kg',
                              style: AppTheme.bodyTextLight.copyWith(
                                color: AppTheme.textSecondaryOf(context),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: croissances.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.poids)).toList(),
                          isCurved: true,
                          color: AppTheme.primaryPurple,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
        ],
        Row(
          children: [
            Expanded(
              child: CustomCard(
                child: Column(
                  children: [
                    Icon(Icons.restaurant, color: AppTheme.primaryPurple),
                    const SizedBox(height: 8),
                    Text('${alimentations.length}', style: AppTheme.statValue),
                    Text('Alim.', style: AppTheme.statLabel),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: CustomCard(
                child: Column(
                  children: [
                    Icon(Icons.favorite, color: AppTheme.errorRed),
                    const SizedBox(height: 8),
                    Text('${santes.length}', style: AppTheme.statValue),
                    Text('Soins', style: AppTheme.statLabel),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        if (croissances.isNotEmpty)
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dernières mesures',
                  style: AppTheme.cardTitle.copyWith(
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                ...croissances.take(5).map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, color: AppTheme.primaryPurple),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${c.poids} kg', style: AppTheme.listItemTitle),
                                Text(
                                  '${c.date.day}/${c.date.month}/${c.date.year}',
                                  style: AppTheme.listItemSubtitle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
      ],
    );
  }
}