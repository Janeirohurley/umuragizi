import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/animal_provider.dart';
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

  void _showAnimalBottomSheet() {
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
              'Sélectionner un animal',
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
    final animaux = context.watch<AnimalProvider>().animaux;
    
    // Initialize selected animal if null and animals exist
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
          'Statistiques',
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
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingXXLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.bar_chart, size: AppTheme.iconSizeXLarge, color: AppTheme.primaryPurple),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    'Aucun animal',
                    style: AppTheme.sectionTitle.copyWith(
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    'Ajoutez un animal pour voir les statistiques',
                    style: AppTheme.bodyTextSecondary.copyWith(
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppTheme.spacingXLarge),
              children: [
                GestureDetector(
                  onTap: _showAnimalBottomSheet,
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
                            _selectedAnimalId == null ? 'Sélectionner un animal' : (selectedAnimal?.nom ?? 'Sélectionner un animal'),
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
                if (_selectedAnimalId != null) _buildStatistics(_selectedAnimalId!),
              ],
            ),
    );
  }

  Widget _buildStatistics(String animalId) {
    final croissances = DatabaseService.getCroissancesParAnimal(animalId);
    final alimentations = DatabaseService.getAlimentationsParAnimal(animalId);
    final santes = DatabaseService.getSantesParAnimal(animalId);

    return Column(
      children: [
        if (croissances.isNotEmpty) ...[
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Évolution du poids',
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
                          color: AppTheme.primaryGreen,
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
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Icon(Icons.restaurant, size: AppTheme.iconSizeLarge, color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text(
                      '${alimentations.length}',
                      style: AppTheme.statValue.copyWith(
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                    Text(
                      'Alimentations',
                      style: AppTheme.statLabel.copyWith(
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: CustomCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Icon(Icons.favorite, size: AppTheme.iconSizeLarge, color: AppTheme.errorRed),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text(
                      '${santes.length}',
                      style: AppTheme.statValue.copyWith(
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                    Text(
                      'Soins',
                      style: AppTheme.statLabel.copyWith(
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
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
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingSmall),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Icon(Icons.trending_up, size: AppTheme.iconSizeSmall, color: AppTheme.primaryGreen),
                          ),
                          const SizedBox(width: AppTheme.spacingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${c.poids} kg',
                                  style: AppTheme.listItemTitle.copyWith(
                                    color: AppTheme.textPrimaryOf(context),
                                  ),
                                ),
                                Text(
                                  '${c.date.day}/${c.date.month}/${c.date.year}',
                                  style: AppTheme.listItemSubtitle.copyWith(
                                    color: AppTheme.textSecondaryOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (c.etatPhysique != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingXSmall),
                              decoration: BoxDecoration(
                                color: AppTheme.lightPurple,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Text(
                                c.etatPhysique!,
                                style: AppTheme.tagText,
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