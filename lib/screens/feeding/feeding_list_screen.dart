import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/animal_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import 'feeding_form_screen.dart';

class FeedingListScreen extends StatefulWidget {
  const FeedingListScreen({super.key});

  @override
  State<FeedingListScreen> createState() => _FeedingListScreenState();
}

class _FeedingListScreenState extends State<FeedingListScreen> {
  String? _selectedAnimalId;

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
          'Suivi Alimentaire',
          style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        centerTitle: true,
        actions: [
          if (_selectedAnimalId != null)
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(AppTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(Icons.add, color: Colors.white, size: AppTheme.iconSizeMedium),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedingFormScreen(animalId: _selectedAnimalId!),
                ),
              ).then((_) => setState(() {})),
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
                      color: AppTheme.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.pets, size: AppTheme.iconSizeXLarge * 1.5, color: AppTheme.primaryGreen),
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
                SizedBox(height: AppTheme.spacingXLarge),
                if (_selectedAnimalId != null) _buildAlimentationList(_selectedAnimalId!),
              ],
            ),
    );
  }

  Widget _buildAlimentationList(String animalId) {
    final alimentations = DatabaseService.getAlimentationsParAnimal(animalId);

    if (alimentations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.restaurant, size: AppTheme.iconSizeXLarge * 1.5, color: AppTheme.primaryGreen),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Aucune alimentation',
              style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Aucune alimentation enregistrée',
              style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),
            PrimaryButton(
              text: 'Ajouter',
              icon: Icons.add,
              width: 200,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedingFormScreen(animalId: animalId)),
              ).then((_) => setState(() {})),
            ),
          ],
        ),
      );
    }

    return Column(
      children: alimentations.map((alim) => Padding(
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
                child: Icon(Icons.restaurant, color: AppTheme.primaryGreen, size: AppTheme.iconSizeLarge),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alim.typeAliment,
                      style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                    ),
                    SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      '${alim.quantite} ${alim.unite}',
                      style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context)),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy à HH:mm', 'fr_FR').format(alim.date),
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
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXLarge)),
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingXXLarge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppTheme.spacingLarge),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                size: AppTheme.iconSizeXLarge,
                                color: AppTheme.errorRed,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacingXLarge),
                            Text(
                              'Supprimer l\'alimentation',
                              style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                            ),
                            SizedBox(height: AppTheme.spacingMedium),
                            Text(
                              'Voulez-vous vraiment supprimer cette entrée ?',
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                            ),
                            SizedBox(height: AppTheme.spacingXXLarge),
                            Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    text: 'Annuler',
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                SizedBox(width: AppTheme.spacingMedium),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      DatabaseService.supprimerAlimentation(alim.id);
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.errorRed,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingMedium),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                      ),
                                    ),
                                    child: Text(
                                      'Supprimer',
                                      style: AppTheme.bodyText.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
