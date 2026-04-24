import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../models/models.dart';
import '../../providers/animal_provider.dart';
import '../../services/database_service.dart';
import '../../services/pdf_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import 'animal_form_screen.dart';
import 'reproduction_form_screen.dart';
import '../finance/transaction_form_screen.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/currency_helper.dart';

class AnimalDetailScreen extends StatefulWidget {
  final String animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {

  void _showQRCode(Animal animal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: AppTheme.spacingXLarge,
              offset: Offset(0, -AppTheme.spacingXSmall),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: AppTheme.spacingMedium),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLightOf(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLarge,
                          ),
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: animal.photoBase64 != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLarge,
                                ),
                                child: Image.memory(
                                  base64Decode(animal.photoBase64!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.pets,
                                color: Colors.white,
                                size: AppTheme.iconSizeLarge,
                              ),
                      ),
                      SizedBox(width: AppTheme.spacingLarge),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              animal.nom,
                              style: AppTheme.sectionTitle.copyWith(
                                fontSize: 20,
                                color: AppTheme.textPrimaryOf(context),
                              ),
                            ),
                            SizedBox(height: AppTheme.spacingXSmall),
                            Text(
                              '${animal.espece} • ${animal.race}',
                              style: AppTheme.bodyTextSecondary.copyWith(
                                fontSize: 13,
                                color: AppTheme.textSecondaryOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceColorOf(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.textSecondaryOf(context),
                          size: AppTheme.iconSizeMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingXXLarge),
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingXXLarge),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusXLarge,
                      ),
                      border: Border.all(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: animal.identifiant,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppTheme.primaryPurple,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppTheme.darkPurple,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingLarge),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLarge,
                            vertical: AppTheme.spacingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightPurple,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tag,
                                size: AppTheme.iconSizeSmall,
                                color: AppTheme.primaryPurple,
                              ),
                              SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                animal.identifiant,
                                style: AppTheme.bodyTextLight.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryPurple,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXLarge),
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColorOf(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppTheme.spacingSmall),
                          decoration: BoxDecoration(
                            color: AppTheme.infoBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            size: AppTheme.iconSizeMedium,
                            color: AppTheme.infoBlue,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingMedium),
                        Expanded(
                          child: Text(
                            'Scannez ce code pour identifier rapidement cet animal',
                            style: AppTheme.bodyTextSecondary.copyWith(
                              fontSize: 13,
                              color: AppTheme.textSecondaryOf(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAnimal(Animal animal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: AppTheme.spacingXLarge,
              offset: Offset(0, -AppTheme.spacingXSmall),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: AppTheme.spacingMedium),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLightOf(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: AppTheme.iconSizeXLarge,
                      color: AppTheme.errorRed,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXLarge),
                  Text(
                    'Supprimer ${animal.nom} ?',
                    style: AppTheme.sectionTitle.copyWith(
                      fontSize: 20,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingMedium),
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColorOf(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                            color: AppTheme.primaryPurple.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          child: animal.photoBase64 != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                  child: Image.memory(
                                    base64Decode(animal.photoBase64!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
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
                                style: AppTheme.cardTitle.copyWith(
                                  fontSize: 15,
                                  color: AppTheme.textPrimaryOf(context),
                                ),
                              ),
                              Text(
                                '${animal.espece} • ${animal.race}',
                                style: AppTheme.bodyTextSecondary.copyWith(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryOf(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingLarge),
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      border: Border.all(
                        color: AppTheme.errorRed.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: AppTheme.iconSizeMedium,
                          color: AppTheme.errorRed,
                        ),
                        SizedBox(width: AppTheme.spacingMedium),
                        Expanded(
                          child: Text(
                            'Cette action est irréversible. Toutes les données associées seront supprimées.',
                            style: AppTheme.bodyTextSecondary.copyWith(
                              fontSize: 13,
                              color: AppTheme.textSecondaryOf(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXXLarge),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                              side: BorderSide(
                                color: AppTheme.textLightOf(
                                  context,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Text(
                            'Annuler',
                            style: AppTheme.cardTitle.copyWith(
                              color: AppTheme.textPrimaryOf(context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AnimalProvider>().supprimerAnimal(
                              animal.id,
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: AppTheme.iconSizeMedium,
                              ),
                              SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                'Supprimer',
                                style: AppTheme.cardTitle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animal = context.watch<AnimalProvider>().getAnimal(widget.animalId);

    if (animal == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColorOf(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.noData, style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
        ),
        body: Center(child: Text(l10n.noData, style: AppTheme.bodyText.copyWith(color: AppTheme.textPrimaryOf(context)))),
      );
    }

    return DefaultTabController(
      length: animal.sexe == 'Femelle' ? 6 : 5,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColorOf(context),
        body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryPurple,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
                onPressed: () => _showQRCode(animal),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  final repros = context.read<ReproductionProvider>().filtrerParAnimal(animal.id);
                  final transactions = context.read<FinanceProvider>().transactions.where((tx) => tx.animalId == animal.id).toList();
                  final settings = context.read<SettingsProvider>();
                  PdfService.generateAnimalReport(
                    animal: animal,
                    repros: repros,
                    transactions: transactions,
                    currency: settings.currency,
                    locale: settings.intlLocale,
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimalFormScreen(animal: animal),
                  ),
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: AppTheme.errorRed,
                    size: 20,
                  ),
                ),
                onPressed: () => _deleteAnimal(animal),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (animal.photoBase64 != null)
                    Image.memory(
                      base64Decode(animal.photoBase64!),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: AppTheme.primaryPurple,
                      child: const Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.nom,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${animal.espece} • ${animal.race}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: AppTheme.textSecondaryOf(context),
                indicatorColor: AppTheme.primaryPurple,
                tabs: [
                  Tab(icon: const Icon(Icons.info_outline, size: 20), text: l10n.dashboard), // Info
                  if (animal.sexe == 'Femelle')
                    Tab(
                      icon: const Icon(Icons.family_restroom, size: 20),
                      text: l10n.reproduction,
                    ),
                  const Tab(icon: Icon(Icons.restaurant, size: 20), text: 'Alim.'),
                  const Tab(
                    icon: Icon(Icons.favorite_outline, size: 20),
                    text: 'Santé',
                  ),
                  Tab(
                    icon: const Icon(Icons.attach_money, size: 20),
                    text: l10n.finance,
                  ),
                  const Tab(
                    icon: Icon(Icons.notifications_outlined, size: 20),
                    text: 'Rappels',
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          children: [
            _InfoTab(animal: animal),
            if (animal.sexe == 'Femelle') _ReproductionTab(animal: animal),
            _AlimentationTab(animalId: animal.id),
            _SanteTab(animalId: animal.id),
            _FinancesTab(animal: animal),
            _RappelsTab(animalId: animal.id),
          ],
        ),
      ),
    ),
  );
}
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppTheme.cardBackgroundOf(context), child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class _InfoTab extends StatelessWidget {
  final Animal animal;

  const _InfoTab({required this.animal});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      padding: EdgeInsets.all(AppTheme.spacingXLarge),
      children: [
        _InfoCard(
          icon: animal.sexe == 'Mâle' ? Icons.male : Icons.female,
          label: animal.sexe == 'Mâle' ? 'Male' : 'Female', // Note: Add more l10n later
          value: animal.sexe,
          colorIcon: animal.sexe == 'Mâle'
              ? AppTheme.infoBlue
              : const Color(0xFFEC4899),
        ),

        SizedBox(height: AppTheme.spacingMedium),
        _InfoCard(
          icon: Icons.calendar_today_outlined,
          label: 'Date',
          value:
              DateFormat('dd/MM/yyyy', settings.intlLocale).format(animal.dateNaissance),
        ),
        SizedBox(height: AppTheme.spacingMedium),
        _InfoCard(
          icon: Icons.cake_outlined,
          label: 'Âge',
          value: animal.ageFormate,
        ),
        SizedBox(height: AppTheme.spacingMedium),
        _InfoCard(
          icon: Icons.fingerprint,
          label: "Identifiant",
          value: animal.identifiant,
        ),
        if (animal.notes != null) ...[
          SizedBox(height: AppTheme.spacingMedium),
          _InfoCard(
            icon: Icons.edit_note_outlined,
            label: "Notes",
            value: animal.notes!,
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color colorIcon;
  final Color backgroundIcon;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.colorIcon = AppTheme.primaryPurple,
    this.backgroundIcon = AppTheme.lightBlue,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: backgroundIcon,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: colorIcon, size: AppTheme.iconSizeLarge),
          ),
          SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                Text(value, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlimentationTab extends StatelessWidget {
  final String animalId;

  const _AlimentationTab({required this.animalId});

  @override
  Widget build(BuildContext context) {
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
              child: Icon(
                Icons.restaurant,
                size: AppTheme.iconSizeXLarge,
                color: AppTheme.primaryGreen,
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text('Aucune alimentation', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Aucune alimentation enregistrée',
              style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppTheme.spacingXLarge),
      itemCount: alimentations.length,
      itemBuilder: (context, index) {
        final alim = alimentations[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
          child: _InfoCard(
            icon: Icons.restaurant,
            label: alim.typeAliment,
            value: '${alim.date.day}/${alim.date.month}/${alim.date.year}',
            colorIcon: AppTheme.primaryGreen,
            backgroundIcon: AppTheme.lightGreen,
          ),
        );
      },
    );
  }
}

class _SanteTab extends StatelessWidget {
  final String animalId;

  const _SanteTab({required this.animalId});

  @override
  Widget build(BuildContext context) {
    final santes = DatabaseService.getSantesParAnimal(animalId);
    final croissances = DatabaseService.getCroissancesParAnimal(animalId);

    if (santes.isEmpty && croissances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                size: AppTheme.iconSizeXLarge,
                color: AppTheme.errorRed,
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text('Aucune donnée', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingSmall),
            Text('Aucune donnée de santé', style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context))),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(AppTheme.spacingXLarge),
      children: [
        if (croissances.isNotEmpty) ...[
          Text('Croissance', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
          SizedBox(height: AppTheme.spacingMedium),
          ...croissances.map(
            (c) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
              child: _InfoCard(
                icon: Icons.trending_up,
                label: '${c.poids} kg',
                value: '${c.date.day}/${c.date.month}/${c.date.year}',
                colorIcon: AppTheme.primaryGreen ,
                backgroundIcon: AppTheme.lightGreen ,
              ),
             
            ),
          ),
          SizedBox(height: AppTheme.spacingLarge),
        ],
        if (santes.isNotEmpty) ...[
          Text('Santé', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
          SizedBox(height: AppTheme.spacingMedium),
          ...santes.map(
            (s) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
              child: _InfoCard(
                icon: _getIconForType(s.type),
                label: s.type,
                value: '${s.date.day}/${s.date.month}/${s.date.year}',
                colorIcon: _getColorForType(s.type),
                backgroundIcon: _getColorForType(s.type).withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ],
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

class _FinancesTab extends StatelessWidget {
  final Animal animal;

  const _FinancesTab({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final transactions = financeProvider.transactions.where((tx) => tx.animalId == animal.id).toList();
        final settings = context.watch<SettingsProvider>();
        final l10n = AppLocalizations.of(context)!;
        
        double totalDepenses = 0;
        double totalRevenus = 0;
        for (var tx in transactions) {
          if (tx.type == 'Dépense') totalDepenses += tx.montant;
          else totalRevenus += tx.montant;
        }

        final prixAchat = animal.prixAchat ?? 0;
        final investissementTotal = prixAchat + totalDepenses - totalRevenus;

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.all(AppTheme.spacingXLarge),
              children: [
                // Résumé de l'investissement
                CustomCard(
                  padding: EdgeInsets.all(AppTheme.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l10n.netInvestment} sur ${animal.nom}', 
                        style: AppTheme.sectionSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                      const SizedBox(height: 12),
                      _buildSummaryRow(l10n.currency, CurrencyHelper.format(prixAchat, settings), AppTheme.textSecondaryOf(context)),
                      _buildSummaryRow(l10n.expenses, CurrencyHelper.format(totalDepenses, settings), AppTheme.errorRed),
                      _buildSummaryRow(l10n.revenues, CurrencyHelper.format(totalRevenus, settings), AppTheme.successGreen),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      _buildSummaryRow(
                        l10n.netInvestment, 
                        CurrencyHelper.format(investissementTotal, settings), 
                        investissementTotal > 0 ? AppTheme.primaryPurple : AppTheme.successGreen,
                        isBold: true
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.spacingXLarge),

                Text('Historique des transactions', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                const SizedBox(height: 12),

                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Aucune transaction enregistrée',
                        style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                      ),
                    ),
                  )
                else
                  ...transactions.map((tx) {
                    final isRevenu = tx.type == 'Revenu';
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
                      child: CustomCard(
                        padding: EdgeInsets.all(AppTheme.spacingSmall),
                        child: ListTile(
                          leading: Icon(
                            isRevenu ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isRevenu ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                          title: Text(tx.categorie, style: AppTheme.listItemTitle),
                          subtitle: Text(DateFormat('dd MMMM yyyy', settings.intlLocale).format(tx.date)),
                          trailing: Text(
                            '${isRevenu ? '+' : '-'}${CurrencyHelper.format(tx.montant, settings)}',
                            style: TextStyle(
                              color: isRevenu ? AppTheme.successGreen : AppTheme.errorRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 80), // Espace pour le FAB
              ],
            ),
            Positioned(
              bottom: AppTheme.spacingXLarge,
              right: AppTheme.spacingXLarge,
              child: FloatingActionButton(
                heroTag: 'add_finance_detail',
                backgroundColor: AppTheme.primaryPurple,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionFormScreen(animalLie: animal),
                    ),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: TextStyle(
            fontSize: 14, 
            color: color, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal
          )),
        ],
      ),
    );
  }
}

class _RappelsTab extends StatelessWidget {
  final String animalId;

  const _RappelsTab({required this.animalId});

  @override
  Widget build(BuildContext context) {
    final rappels = DatabaseService.getRappelsParAnimal(animalId);

    if (rappels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: AppTheme.iconSizeXLarge,
                color: AppTheme.warningOrange,
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text('Aucun rappel', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingSmall),
            Text('Aucun rappel programmé', style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppTheme.spacingXLarge),
      itemCount: rappels.length,
      itemBuilder: (context, index) {
        final rappel = rappels[index];
        final color = rappel.estComplete
            ? AppTheme.successGreen
            : (rappel.estEnRetard ? AppTheme.errorRed : AppTheme.warningOrange);
        return Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    rappel.estComplete
                        ? Icons.check_circle
                        : Icons.notifications,
                    color: color,
                    size: AppTheme.iconSizeLarge,
                  ),
                ),
                SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rappel.titre, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                      SizedBox(height: AppTheme.spacingXSmall),
                      Text(
                        rappel.description,
                        style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context)),
                      ),
                      Text(
                        '${rappel.dateRappel.day}/${rappel.dateRappel.month}/${rappel.dateRappel.year}',
                        style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReproductionTab extends StatelessWidget {
  final Animal animal;

  const _ReproductionTab({required this.animal});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ReproductionProvider>().chargerReproductions(),
      builder: (context, snapshot) {
        return Consumer<ReproductionProvider>(
          builder: (context, reproductionProvider, child) {
            final reproductions = reproductionProvider.filtrerParAnimal(animal.id);

            return Stack(
              children: [
                if (reproductions.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.family_restroom,
                          size: 64,
                          color: AppTheme.textLightOf(context),
                        ),
                        SizedBox(height: AppTheme.spacingMedium),
                        Text(
                          'Aucun événement de reproduction',
                          style: AppTheme.sectionSubtitle.copyWith(
                            color: AppTheme.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    padding: EdgeInsets.all(AppTheme.spacingXLarge),
                    itemCount: reproductions.length,
                    itemBuilder: (context, index) {
                      final repro = reproductions[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
                        child: CustomCard(
                          padding: EdgeInsets.all(AppTheme.spacingMedium),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(AppTheme.spacingSmall),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Icon(
                                Icons.favorite,
                                color: const Color(0xFFEC4899),
                                size: AppTheme.iconSizeMedium,
                              ),
                            ),
                            title: Text(repro.typeEvenement, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('dd MMMM yyyy').format(repro.dateEvenement), style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                                if (repro.datePrevueMiseBas != null)
                                  Text(
                                    'Vêlage prévu : ${DateFormat('dd/MM/yyyy').format(repro.datePrevueMiseBas!)}',
                                    style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
                                  ),
                                if (repro.notes != null) Text(repro.notes!, style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondaryOf(context))),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: AppTheme.errorRed),
                              onPressed: () {
                                context.read<ReproductionProvider>().supprimerReproduction(repro.id);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Positioned(
                  bottom: AppTheme.spacingXLarge,
                  right: AppTheme.spacingXLarge,
                  child: FloatingActionButton(
                    heroTag: 'add_repro',
                    backgroundColor: const Color(0xFFEC4899),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReproductionFormScreen(animal: animal),
                        ),
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
