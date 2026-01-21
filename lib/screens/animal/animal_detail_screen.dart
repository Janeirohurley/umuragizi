import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../models/models.dart';
import '../../providers/animal_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import 'animal_form_screen.dart';

class AnimalDetailScreen extends StatefulWidget {
  final String animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    final animal = context.watch<AnimalProvider>().getAnimal(widget.animalId);

    if (animal == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColorOf(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Animal introuvable', style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
        ),
        body: Center(child: Text('Cet animal n\'existe plus', style: AppTheme.bodyText.copyWith(color: AppTheme.textPrimaryOf(context)))),
      );
    }

    return Scaffold(
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
                controller: _tabController,
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: AppTheme.textSecondaryOf(context),
                indicatorColor: AppTheme.primaryPurple,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline, size: 20), text: 'Info'),
                  Tab(icon: Icon(Icons.restaurant, size: 20), text: 'Alim.'),
                  Tab(
                    icon: Icon(Icons.favorite_outline, size: 20),
                    text: 'Santé',
                  ),
                  Tab(
                    icon: Icon(Icons.attach_money, size: 20),
                    text: 'Finances',
                  ),
                  Tab(
                    icon: Icon(Icons.notifications_outlined, size: 20),
                    text: 'Rappels',
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _InfoTab(animal: animal),
            _AlimentationTab(animalId: animal.id),
            _SanteTab(animalId: animal.id),
            _FinancesTab(animal: animal),
            _RappelsTab(animalId: animal.id),
          ],
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
    return ListView(
      padding: EdgeInsets.all(AppTheme.spacingXLarge),
      children: [
        _InfoCard(
          icon: animal.sexe == 'Mâle' ? Icons.male : Icons.female,
          label: "Sexe",
          value: animal.sexe,
          colorIcon: animal.sexe == 'Mâle'
              ? AppTheme.infoBlue
              : const Color(0xFFEC4899),
        ),

        SizedBox(height: AppTheme.spacingMedium),
        _InfoCard(
          icon: Icons.calendar_today_outlined,
          label: 'Date de naissance',
          value:
              '${animal.dateNaissance.day}/${animal.dateNaissance.month}/${animal.dateNaissance.year}',
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

class _FinancesTab extends StatefulWidget {
  final Animal animal;

  const _FinancesTab({required this.animal});

  @override
  State<_FinancesTab> createState() => _FinancesTabState();
}

class _FinancesTabState extends State<_FinancesTab> {
  String _filtrePeriode = 'Tout';

  List<Alimentation> _filtrerAlimentations(List<Alimentation> alimentations) {
    final now = DateTime.now();
    switch (_filtrePeriode) {
      case 'Mois':
        return alimentations
            .where(
              (a) => a.date.isAfter(now.subtract(const Duration(days: 30))),
            )
            .toList();
      case 'Semaine':
        return alimentations
            .where((a) => a.date.isAfter(now.subtract(const Duration(days: 7))))
            .toList();
      case 'Année':
        return alimentations
            .where(
              (a) => a.date.isAfter(now.subtract(const Duration(days: 365))),
            )
            .toList();
      default:
        return alimentations;
    }
  }

  List<Sante> _filtrerSantes(List<Sante> santes) {
    final now = DateTime.now();
    switch (_filtrePeriode) {
      case 'Mois':
        return santes
            .where(
              (s) => s.date.isAfter(now.subtract(const Duration(days: 30))),
            )
            .toList();
      case 'Semaine':
        return santes
            .where((s) => s.date.isAfter(now.subtract(const Duration(days: 7))))
            .toList();
      case 'Année':
        return santes
            .where(
              (s) => s.date.isAfter(now.subtract(const Duration(days: 365))),
            )
            .toList();
      default:
        return santes;
    }
  }

  Widget _buildFiltreChip(String label) {
    final isSelected = _filtrePeriode == label;
    return GestureDetector(
      onTap: () => setState(() => _filtrePeriode = label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall - 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : AppTheme.surfaceColorOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          label,
          style: AppTheme.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alimentations = _filtrerAlimentations(
      DatabaseService.getAlimentationsParAnimal(widget.animal.id),
    );
    final santes = _filtrerSantes(
      DatabaseService.getSantesParAnimal(widget.animal.id),
    );

    final coutAlimentation = alimentations.fold<double>(
      0,
      (sum, a) => sum + a.coutTotal,
    );
    final coutSante = santes
        .where((s) => s.estPaye)
        .fold<double>(0, (sum, s) => sum + (s.cout ?? 0));
    final coutTotal =
        (_filtrePeriode == 'Tout' ? (widget.animal.prixAchat ?? 0) : 0) +
        coutAlimentation +
        coutSante;

    return ListView(
      padding: EdgeInsets.all(AppTheme.spacingXLarge),
      children: [
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFiltreChip('Tout'),
              SizedBox(width: AppTheme.spacingSmall),
              _buildFiltreChip('Semaine'),
              SizedBox(width: AppTheme.spacingSmall),
              _buildFiltreChip('Mois'),
              SizedBox(width: AppTheme.spacingSmall),
              _buildFiltreChip('Année'),
            ],
          ),
        ),
        SizedBox(height: AppTheme.spacingLarge),
        CustomCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Coût total${_filtrePeriode != 'Tout' ? ' ($_filtrePeriode)' : ''}',
                    style: AppTheme.sectionTitle.copyWith(
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                  Text(
                    '${coutTotal.toStringAsFixed(2)} €',
                    style: AppTheme.pageTitle.copyWith(
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingLarge),
              if (_filtrePeriode == 'Tout')
                _buildCoutRow(
                  'Prix d\'achat',
                  widget.animal.prixAchat ?? 0,
                  AppTheme.infoBlue,
                ),
              if (_filtrePeriode == 'Tout')
                SizedBox(height: AppTheme.spacingSmall),
              _buildCoutRow(
                'Alimentation',
                coutAlimentation,
                AppTheme.primaryGreen,
              ),
              SizedBox(height: AppTheme.spacingSmall),
              _buildCoutRow('Santé', coutSante, AppTheme.errorRed),
            ],
          ),
        ),
        SizedBox(height: AppTheme.spacingLarge),
        if (widget.animal.mereId != null) ...[
          Text('Généalogie', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
          SizedBox(height: AppTheme.spacingMedium),
          _buildMereCard(widget.animal.mereId!),
          SizedBox(height: AppTheme.spacingLarge),
        ],
        Text('Détails des coûts', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
        SizedBox(height: AppTheme.spacingMedium),
        if (alimentations.isEmpty && santes.isEmpty)
          CustomCard(
            padding: EdgeInsets.all(AppTheme.spacingXXLarge),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      size: AppTheme.iconSizeXLarge,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingLarge),
                  Text('Aucune dépense', style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                ],
              ),
            ),
          )
        else ...[
          ...alimentations
              .where((a) => a.prixUnitaire != null)
              .map(
                (a) => Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
                  child:
                   CustomCard(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppTheme.spacingSmall),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGreen,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: AppTheme.primaryGreen,
                            size: AppTheme.iconSizeMedium,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.typeAliment,
                                style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                              ),
                              Text(
                                '${a.quantite} ${a.unite} × ${a.prixUnitaire}€',
                                style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context)),
                              ),
                              Text(
                                '${a.date.day}/${a.date.month}/${a.date.year}',
                                style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${a.coutTotal.toStringAsFixed(2)} €',
                          style: AppTheme.listItemTitle.copyWith(
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ...santes
              .where((s) => s.cout != null && s.estPaye)
              .map(
                (s) => Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
                  child: CustomCard(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppTheme.spacingSmall),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: Icon(
                            Icons.medical_services,
                            color: AppTheme.errorRed,
                            size: AppTheme.iconSizeMedium,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.description,
                                style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                              ),
                              Text(s.type, style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                              Text(
                                '${s.date.day}/${s.date.month}/${s.date.year}',
                                style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${s.cout!.toStringAsFixed(2)} €',
                          style: AppTheme.listItemTitle.copyWith(
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildCoutRow(String label, double montant, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Expanded(child: Text(label, style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)))),
        Text(
          '${montant.toStringAsFixed(2)} €',
          style: AppTheme.listItemTitle.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildMereCard(String mereId) {
    final mere = DatabaseService.getAnimal(mereId);
    if (mere == null) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: AppTheme.lightPurple,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              Icons.family_restroom,
              color: AppTheme.primaryPurple,
              size: AppTheme.iconSizeLarge,
            ),
          ),
          SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mère', style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                Text(mere.nom, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                Text(
                  '${mere.espece} • ${mere.race}',
                  style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textLight),
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
