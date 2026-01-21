import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/animal_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import 'health_form_screen.dart';
import 'growth_form_screen.dart';

class HealthListScreen extends StatefulWidget {
  const HealthListScreen({super.key});

  @override
  State<HealthListScreen> createState() => _HealthListScreenState();
}

class _HealthListScreenState extends State<HealthListScreen> {
  String? _selectedAnimalId;
  int _selectedTab = 0;

  void _showAnimalBottomSheet() {
    final animaux = context.read<AnimalProvider>().animaux;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppTheme.spacingMedium),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLightOf(context),
                borderRadius: BorderRadius.circular(AppTheme.spacingXSmall),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Sélectionner un animal',
              style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            ...animaux.map((animal) => ListTile(
              leading: Icon(
                Icons.pets,
                color: _selectedAnimalId == animal.id ? AppTheme.primaryPurple : AppTheme.textSecondaryOf(context),
              ),
              title: Text(
                animal.nom,
                style: _selectedAnimalId == animal.id
                    ? AppTheme.listItemTitle.copyWith(color: AppTheme.primaryPurple)
                    : AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
              ),
              trailing: _selectedAnimalId == animal.id
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryPurple)
                  : null,
              onTap: () {
                setState(() => _selectedAnimalId = animal.id);
                Navigator.pop(context);
              },
            )),
            SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animaux = context.watch<AnimalProvider>().animaux;
    final selectedAnimal = _selectedAnimalId != null && animaux.any((a) => a.id == _selectedAnimalId)
        ? animaux.firstWhere((a) => a.id == _selectedAnimalId)
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(AppTheme.spacingSmall),
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
          'Santé & Croissance',
          style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        centerTitle: true,
        actions: [
          if (_selectedAnimalId != null)
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(AppTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(Icons.add, color: Colors.white, size: AppTheme.iconSizeMedium),
              ),
              onPressed: () {
                if (_selectedTab == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HealthFormScreen(animalId: _selectedAnimalId!)),
                  ).then((_) => setState(() {}));
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GrowthFormScreen(animalId: _selectedAnimalId!)),
                  ).then((_) => setState(() {}));
                }
              },
            ),
          SizedBox(width: AppTheme.spacingSmall),
        ],
      ),
      body: animaux.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingXXLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.lightRed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.pets, size: AppTheme.iconSizeXLarge * 1.5, color: AppTheme.errorRed),
                  ),
                  SizedBox(height: AppTheme.spacingLarge),
                  Text(
                    'Aucun animal',
                    style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    'Ajoutez un animal pour commencer',
                    style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(AppTheme.spacingXLarge),
              children: [
                GestureDetector(
                  onTap: _showAnimalBottomSheet,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColorOf(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pets, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                        SizedBox(width: AppTheme.spacingMedium),
                        Expanded(
                          child: Text(
                            _selectedAnimalId == null ? 'Sélectionner un animal' : (selectedAnimal?.nom ?? 'Sélectionner un animal'),
                            style: _selectedAnimalId == null ? AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)) : AppTheme.bodyText.copyWith(color: AppTheme.textPrimaryOf(context)),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: AppTheme.textLightOf(context)),
                      ],
                    ),
                  ),
                ),
                if (_selectedAnimalId != null) ...[
                  SizedBox(height: AppTheme.spacingXLarge),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0 ? AppTheme.errorRed : AppTheme.surfaceColorOf(context),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: AppTheme.iconSizeSmall,
                                  color: _selectedTab == 0 ? Colors.white : AppTheme.errorRed,
                                ),
                                SizedBox(width: AppTheme.spacingSmall),
                                Text(
                                  'Santé',
                                  style: AppTheme.bodyText.copyWith(
                                    color: _selectedTab == 0 ? Colors.white : AppTheme.textSecondaryOf(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1 ? AppTheme.primaryGreen : AppTheme.surfaceColorOf(context),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: AppTheme.iconSizeSmall,
                                  color: _selectedTab == 1 ? Colors.white : AppTheme.primaryGreen,
                                ),
                                SizedBox(width: AppTheme.spacingSmall),
                                Text(
                                  'Croissance',
                                  style: AppTheme.bodyText.copyWith(
                                    color: _selectedTab == 1 ? Colors.white : AppTheme.textSecondaryOf(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingXLarge),
                  _selectedTab == 0
                      ? _buildSanteList(_selectedAnimalId!)
                      : _buildCroissanceList(_selectedAnimalId!),
                ],
              ],
            ),
    );
  }

  Widget _buildSanteList(String animalId) {
    final santes = DatabaseService.getSantesParAnimal(animalId);

    if (santes.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: AppTheme.spacingXXLarge),
            Container(
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              decoration: BoxDecoration(
                color: AppTheme.lightRed,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite, size: AppTheme.iconSizeXLarge * 1.5, color: AppTheme.errorRed),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Aucune donnée',
              style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Aucune donnée de santé',
              style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),
            PrimaryButton(
              text: 'Ajouter',
              icon: Icons.add,
              width: 200,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HealthFormScreen(animalId: animalId)),
              ).then((_) => setState(() {})),
            ),
          ],
        ),
      );
    }

    return Column(
      children: santes.map((sante) => Padding(
        padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
        child: CustomCard(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: _getColorForType(sante.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(_getIconForType(sante.type), color: _getColorForType(sante.type), size: AppTheme.iconSizeLarge),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sante.description,
                      style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                    ),
                    SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      sante.type,
                      style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context)),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy', 'fr_FR').format(sante.date),
                      style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(AppTheme.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(Icons.delete_outline, color: AppTheme.errorRed, size: AppTheme.iconSizeSmall),
                ),
                onPressed: () {
                  DatabaseService.supprimerSante(sante.id);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCroissanceList(String animalId) {
    final croissances = DatabaseService.getCroissancesParAnimal(animalId);

    if (croissances.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: AppTheme.spacingXXLarge),
            Container(
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.trending_up, size: AppTheme.iconSizeXLarge * 1.5, color: AppTheme.primaryGreen),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Aucune donnée',
              style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Aucune donnée de croissance',
              style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),
            PrimaryButton(
              text: 'Ajouter',
              icon: Icons.add,
              width: 200,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GrowthFormScreen(animalId: animalId)),
              ).then((_) => setState(() {})),
            ),
          ],
        ),
      );
    }

    return Column(
      children: croissances.map((croissance) => Padding(
        padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
        child: CustomCard(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(Icons.trending_up, color: AppTheme.primaryGreen, size: AppTheme.iconSizeLarge),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${croissance.poids} kg',
                      style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                    ),
                    if (croissance.taille != null) ...[
                      SizedBox(height: AppTheme.spacingXSmall),
                      Text(
                        'Taille: ${croissance.taille} cm',
                        style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context)),
                      ),
                    ],
                    Text(
                      DateFormat('d MMMM yyyy', 'fr_FR').format(croissance.date),
                      style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(AppTheme.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(Icons.delete_outline, color: AppTheme.errorRed, size: AppTheme.iconSizeSmall),
                ),
                onPressed: () {
                  DatabaseService.supprimerCroissance(croissance.id);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return AppTheme.primaryPurple;
      case 'traitement':
        return AppTheme.infoBlue;
      case 'maladie':
        return AppTheme.errorRed;
      case 'visite':
        return AppTheme.successGreen;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines;
      case 'traitement':
        return Icons.medication;
      case 'maladie':
        return Icons.sick;
      case 'visite':
        return Icons.local_hospital;
      default:
        return Icons.favorite;
    }
  }
}
