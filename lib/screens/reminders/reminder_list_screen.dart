import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/animal_provider.dart';
import '../../providers/rappel_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import 'reminder_form_screen.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  String? _selectedAnimalId;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Tous', 'En retard', "Aujourd'hui", 'À venir'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildAnimalSelector(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(child: _buildRappelsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "reminder_list_fab",
        onPressed: _selectedAnimalId != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderFormScreen(animalId: _selectedAnimalId!),
                  ),
                )
            : () => _showSelectAnimalDialog(),
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingXLarge, AppTheme.spacingLarge, AppTheme.spacingXLarge, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mes Tâches',
            style: AppTheme.pageTitle,
          ),
          Consumer<RappelProvider>(
            builder: (context, provider, _) {
              final total = provider.rappels.where((r) => !r.estComplete).length;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: AppTheme.lightPurple,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  '$total en cours',
                  style: AppTheme.tagText,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return Consumer<AnimalProvider>(
      builder: (context, animalProvider, _) {
        final animaux = animalProvider.animaux;

        if (animaux.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedAnimal = _selectedAnimalId != null
            ? animaux.firstWhere((a) => a.id == _selectedAnimalId, orElse: () => animaux.first)
            : null;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
          child: GestureDetector(
            onTap: () => _showAnimalBottomSheet(animaux),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeMedium),
                  SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: Text(
                      selectedAnimal?.nom ?? 'Tous les animaux',
                      style: _selectedAnimalId == null
                          ? AppTheme.formHint.copyWith(color: AppTheme.textLightOf(context))
                          : AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context)),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeLarge),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAnimalBottomSheet(List<Animal> animaux) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppTheme.spacingXLarge),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppTheme.spacingXLarge),
            Text(
              'Sélectionner un animal',
              style: AppTheme.bottomSheetTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: animaux.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColorOf(context),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Icon(Icons.pets, color: AppTheme.primaryPurple, size: AppTheme.iconSizeSmall),
                      ),
                      title: Text('Tous les animaux', style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                      trailing: _selectedAnimalId == null
                          ? Icon(Icons.check, color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium)
                          : null,
                      onTap: () {
                        setState(() => _selectedAnimalId = null);
                        Navigator.pop(context);
                      },
                    );
                  }
                  final animal = animaux[index - 1];
                  final isSelected = _selectedAnimalId == animal.id;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.lightPurple,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Icon(Icons.pets, color: AppTheme.primaryPurple, size: AppTheme.iconSizeSmall),
                    ),
                    title: Text(
                      animal.nom,
                      style: isSelected
                          ? AppTheme.listItemTitle.copyWith(color: AppTheme.primaryPurple)
                          : AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                    ),
                    subtitle: Text('${animal.espece} • ${animal.race}', style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                    trailing: isSelected
                        ? Icon(Icons.check, color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium)
                        : null,
                    onTap: () {
                      setState(() => _selectedAnimalId = animal.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilterIndex == index;

          Color? badgeColor;
          int? badgeCount;

          final rappelProvider = context.watch<RappelProvider>();
          if (index == 1) {
            badgeCount = rappelProvider.nombreRappelsEnRetard;
            badgeColor = AppTheme.errorRed;
          } else if (index == 2) {
            badgeCount = rappelProvider.nombreRappelsDuJour;
            badgeColor = AppTheme.warningOrange;
          }

          return Padding(
            padding: EdgeInsets.only(right: index < _filters.length - 1 ? AppTheme.spacingSmall : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryPurple : AppTheme.cardBackgroundOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryPurple : AppTheme.surfaceColorOf(context),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter,
                      style: AppTheme.bodyText.copyWith(
                        color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (badgeCount != null && badgeCount > 0) ...[
                      SizedBox(width: AppTheme.spacingSmall - 2),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall - 2, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : badgeColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: AppTheme.bodyTextLight.copyWith(
                            color: isSelected ? AppTheme.primaryPurple : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRappelsList() {
    return Consumer<RappelProvider>(
      builder: (context, rappelProvider, _) {
        List<Rappel> rappels = _selectedAnimalId == null
            ? rappelProvider.rappels.where((r) => !r.estComplete).toList()
            : rappelProvider.getRappelsParAnimal(_selectedAnimalId!).where((r) => !r.estComplete).toList();

        // Apply filter
        switch (_selectedFilterIndex) {
          case 1: // En retard
            rappels = rappels.where((r) => r.estEnRetard).toList();
            break;
          case 2: // Aujourd'hui
            rappels = rappels.where((r) => r.estAujourdhui).toList();
            break;
          case 3: // À venir
            rappels = rappels.where((r) => !r.estEnRetard && !r.estAujourdhui).toList();
            break;
        }

        if (rappels.isEmpty) {
          return Center(
            
            child: CustomCard(
              margin: EdgeInsets.all(AppTheme.spacingXLarge),
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: _selectedFilterIndex == 0
                          ? AppTheme.lightGreen
                          : AppTheme.lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedFilterIndex == 0
                          ? Icons.check_circle_outline
                          : Icons.notifications_off_outlined,
                      size: AppTheme.iconSizeXLarge,
                      color: _selectedFilterIndex == 0
                          ? AppTheme.successGreen
                          : AppTheme.primaryPurple,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXLarge),
                  Text(
                    _selectedFilterIndex == 0
                        ? 'Tout est à jour !'
                        : 'Aucune tâche',
                    style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    _getEmptyMessage(),
                    style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedAnimalId != null) ...[
                    SizedBox(height: AppTheme.spacingXXLarge),
                    PrimaryButton(
                      text: 'Ajouter une tâche',
                      icon: Icons.add,
                      width: 200,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReminderFormScreen(animalId: _selectedAnimalId!),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Group by status for "Tous" filter
        if (_selectedFilterIndex == 0) {
          final enRetard = rappels.where((r) => r.estEnRetard).toList();
          final aujourdhui = rappels.where((r) => r.estAujourdhui && !r.estEnRetard).toList();
          final aVenir = rappels.where((r) => !r.estEnRetard && !r.estAujourdhui).toList();

          return ListView(
            padding: EdgeInsets.fromLTRB(AppTheme.spacingXLarge, 0, AppTheme.spacingXLarge, 100),
            children: [
              if (enRetard.isNotEmpty) ...[
                _buildSectionHeader('En retard', AppTheme.errorRed, enRetard.length),
                SizedBox(height: AppTheme.spacingMedium),
                ...enRetard.map((r) => _ModernRappelCard(rappel: r)),
                SizedBox(height: AppTheme.spacingXLarge),
              ],
              if (aujourdhui.isNotEmpty) ...[
                _buildSectionHeader("Aujourd'hui", AppTheme.warningOrange, aujourdhui.length),
                SizedBox(height: AppTheme.spacingMedium),
                ...aujourdhui.map((r) => _ModernRappelCard(rappel: r)),
                SizedBox(height: AppTheme.spacingXLarge),
              ],
              if (aVenir.isNotEmpty) ...[
                _buildSectionHeader('À venir', AppTheme.primaryPurple, aVenir.length),
                SizedBox(height: AppTheme.spacingMedium),
                ...aVenir.map((r) => _ModernRappelCard(rappel: r)),
              ],
            ],
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(AppTheme.spacingXLarge, 0, AppTheme.spacingXLarge, 100),
          itemCount: rappels.length,
          itemBuilder: (context, index) {
            return _ModernRappelCard(rappel: rappels[index]);
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Text(
          title,
          style: AppTheme.sectionTitle.copyWith(color: color),
        ),
        SizedBox(width: AppTheme.spacingSmall),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Text(
            '$count',
            style: AppTheme.bodyText.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _getEmptyMessage() {
    switch (_selectedFilterIndex) {
      case 1:
        return 'Aucune tâche en retard';
      case 2:
        return "Aucune tâche pour aujourd'hui";
      case 3:
        return 'Aucune tâche à venir';
      default:
        return 'Aucune tâche programmée';
    }
  }

  void _showSelectAnimalDialog() {
    final animaux = context.read<AnimalProvider>().animaux;

    if (animaux.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ajoutez d\'abord un animal', style: AppTheme.bodyText.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppTheme.spacingXLarge),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingXLarge),
            const Text(
              'Sélectionner un animal',
              style: AppTheme.bottomSheetTitle,
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: animaux.length,
                itemBuilder: (context, index) {
                  final animal = animaux[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingXSmall),
                    leading: Container(
                      width: AppTheme.iconSizeXLarge,
                      height: AppTheme.iconSizeXLarge,
                      decoration: BoxDecoration(
                        color: AppTheme.lightPurple,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Icon(Icons.pets, color: AppTheme.primaryPurple, size: AppTheme.iconSizeSmall),
                    ),
                    title: Text(animal.nom, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                    subtitle: Text('${animal.espece} • ${animal.race}', style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReminderFormScreen(animalId: animal.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }
}

class _ModernRappelCard extends StatelessWidget {
  final Rappel rappel;

  const _ModernRappelCard({required this.rappel});

  @override
  Widget build(BuildContext context) {
    final isEnRetard = rappel.estEnRetard;
    final isAujourdhui = rappel.estAujourdhui;

    Color statusColor;
    String statusText;

    if (isEnRetard) {
      statusColor = AppTheme.errorRed;
      statusText = 'En retard';
    } else if (isAujourdhui) {
      statusColor = AppTheme.warningOrange;
      statusText = "Aujourd'hui";
    } else {
      statusColor = AppTheme.primaryPurple;
      statusText = DateFormat('d MMM', 'fr_FR').format(rappel.dateRappel);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: CustomCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                await NotificationService.markReminderComplete(rappel.id);
                context.read<RappelProvider>().marquerComplete(rappel.id);
              },
              child: Container(
                width: AppTheme.iconSizeLarge,
                height: AppTheme.iconSizeLarge,
                margin: EdgeInsets.only(top: AppTheme.spacingXSmall / 2),
                decoration: BoxDecoration(
                  border: Border.all(color: statusColor, width: 2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall - 2),
                ),
                child: Icon(Icons.check, size: AppTheme.iconSizeSmall, color: Colors.transparent),
              ),
            ),
            SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingXSmall),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          statusText,
                          style: AppTheme.bodyTextSecondary.copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingXSmall),
                        decoration: BoxDecoration(
                          color: _getColorForType(rappel.type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForType(rappel.type),
                              size: AppTheme.iconSizeSmall,
                              color: _getColorForType(rappel.type),
                            ),
                            SizedBox(width: AppTheme.spacingXSmall),
                            Text(
                              rappel.type,
                              style: AppTheme.bodyTextSecondary.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _getColorForType(rappel.type),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    rappel.titre,
                    style: AppTheme.cardTitle.copyWith(fontSize: 16, color: AppTheme.textPrimaryOf(context)),
                  ),
                  if (rappel.description.isNotEmpty) ...[
                    SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      rappel.description,
                      style: AppTheme.cardSubtitle.copyWith(fontSize: 14, color: AppTheme.textSecondaryOf(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (rappel.recurrent) ...[
                    SizedBox(height: AppTheme.spacingSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          size: AppTheme.iconSizeSmall - 2,
                          color: AppTheme.textLightOf(context),
                        ),
                        SizedBox(width: AppTheme.spacingXSmall),
                        Text(
                          rappel.intervalleHeures != null
                              ? 'Récurrent (${rappel.intervalleHeures} heures)'
                              : 'Récurrent (${rappel.intervalleJours} jours)',
                          style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondaryOf(context)),
                        ),
                      ],
                    ),
                  ],
                  if (rappel.dateFin != null) ...[
                    SizedBox(height: AppTheme.spacingXSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: AppTheme.iconSizeSmall - 2,
                          color: AppTheme.textLightOf(context),
                        ),
                        SizedBox(width: AppTheme.spacingXSmall),
                        Text(
                          'Jusqu\'au ${DateFormat('d MMM yyyy', 'fr_FR').format(rappel.dateFin!)}',
                          style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondaryOf(context)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: AppTheme.spacingSmall),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeMedium),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReminderFormScreen(animalId: rappel.animalId, rappel: rappel),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: AppTheme.spacingSmall),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeMedium),
                  onPressed: () => _showDeleteConfirmation(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
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
                color: AppTheme.textLightOf(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppTheme.spacingXLarge),
            Container(
              width: AppTheme.iconSizeXLarge * 2.25,
              height: AppTheme.iconSizeXLarge * 2.25,
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: AppTheme.iconSizeXLarge + 4,
                color: AppTheme.errorRed,
              ),
            ),
            SizedBox(height: AppTheme.spacingXLarge),
            Text(
              'Supprimer la tâche ?',
              style: AppTheme.sectionTitle.copyWith(fontSize: 20, color: AppTheme.textPrimaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXXLarge),
              child: Text(
                'Voulez-vous vraiment supprimer "${rappel.titre}" ?',
                style: AppTheme.cardSubtitle.copyWith(fontSize: 14, color: AppTheme.textSecondaryOf(context)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingXLarge),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium + 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          side: BorderSide(color: AppTheme.surfaceColorOf(context)),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: AppTheme.buttonText.copyWith(
                          fontSize: 14,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await NotificationService.cancelReminderNotification(rappel.id);
                        context.read<RappelProvider>().supprimerRappel(rappel.id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium + 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                      ),
                      child: Text(
                        'Supprimer',
                        style: AppTheme.buttonText.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines;
      case 'vermifuge':
        return Icons.medication;
      case 'visite vétérinaire':
        return Icons.local_hospital;
      case 'soin spécifique':
        return Icons.healing;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return AppTheme.primaryPurple;
      case 'vermifuge':
        return AppTheme.accentOrange;
      case 'visite vétérinaire':
        return AppTheme.infoBlue;
      case 'soin spécifique':
        return AppTheme.successGreen;
      default:
        return AppTheme.textSecondary;
    }
  }
}
