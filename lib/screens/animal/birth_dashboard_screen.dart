import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/animal_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';

class BirthDashboardScreen extends StatelessWidget {
  const BirthDashboardScreen({super.key});

  int _getGestationDays(String espece) {
    switch (espece.toLowerCase()) {
      case 'bovin': return 283;
      case 'équin': return 340;
      case 'ovin': return 152;
      case 'caprin': return 150;
      case 'porcin': return 114;
      default: return 283;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        title: Text(
          'Prochaines Naissances',
          style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimaryOf(context)),
      ),
      body: Consumer2<ReproductionProvider, AnimalProvider>(
        builder: (context, reproProvider, animalProvider, child) {
          final naissances = reproProvider.prochainesNaissances;

          if (naissances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care_outlined, size: 80, color: AppTheme.textLightOf(context).withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune naissance prévue',
                    style: AppTheme.sectionTitle.copyWith(color: AppTheme.textSecondaryOf(context)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppTheme.spacingXLarge),
            itemCount: naissances.length,
            itemBuilder: (context, index) {
              final repro = naissances[index];
              final animal = animalProvider.getAnimal(repro.animalId);
              
              if (animal == null) return const SizedBox.shrink();

              final now = DateTime.now();
              final joursRestants = repro.datePrevueMiseBas!.difference(now).inDays;
              final joursGestation = _getGestationDays(animal.espece);
              
              // Progression (estimation)
              final joursEcoules = joursGestation - joursRestants;
              final progression = (joursEcoules / joursGestation).clamp(0.0, 1.0);

              return Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacingLarge),
                child: CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
                          child: Icon(Icons.pets, color: AppTheme.primaryPurple),
                        ),
                        title: Text(animal.nom, style: AppTheme.cardTitle),
                        subtitle: Text('${animal.espece} • ${animal.race}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: joursRestants < 7 ? AppTheme.errorRed : AppTheme.successGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'J-$joursRestants',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Gestation', style: AppTheme.bodyTextSecondary),
                                Text(
                                  'Mise bas prévue : ${DateFormat('dd MMMM yyyy', 'fr_FR').format(repro.datePrevueMiseBas!)}',
                                  style: AppTheme.bodyTextSecondary.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progression,
                                minHeight: 8,
                                backgroundColor: AppTheme.surfaceColorOf(context),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  joursRestants < 7 ? AppTheme.errorRed : AppTheme.primaryPurple,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
