import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../l10n/app_localizations.dart';
import '../../providers/animal_provider.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import 'animal_form_screen.dart';
import 'animal_detail_screen.dart';

class AnimalListScreen extends StatefulWidget {
  final String? initialFilter;

  const AnimalListScreen({super.key, this.initialFilter});

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  late String _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'Tous';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            SizedBox(height: AppTheme.spacingLarge),
            _buildSearchBar(l10n),
            SizedBox(height: AppTheme.spacingLarge),
            _buildFilters(l10n),
            SizedBox(height: AppTheme.spacingLarge),
            Expanded(child: _buildAnimalList(l10n)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "animal_list_fab",
        onPressed: () => _navigateToAddAnimal(context),
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingXLarge, AppTheme.spacingLarge, AppTheme.spacingXLarge, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.animals,
            style: AppTheme.pageTitle,
          ),
          Consumer<AnimalProvider>(
            builder: (context, provider, _) => Container(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: AppTheme.lightPurple,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                '${provider.nombreAnimauxActifs} actifs / ${provider.nombreAnimaux}',
                style: AppTheme.tagText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textPrimaryOf(context)),
          decoration: InputDecoration(
            hintText: '...',
            hintStyle: AppTheme.bodyTextLight.copyWith(fontWeight: FontWeight.w900, color: AppTheme.textLightOf(context)),
            prefixIcon: Icon(Icons.search, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeMedium),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeMedium),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(
                color: AppTheme.primaryPurple,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge, vertical: AppTheme.spacingMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return Consumer<AnimalProvider>(
      builder: (context, provider, _) {
        final especes = [l10n.all, ...provider.especes];

        return SizedBox(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
            itemCount: especes.length,
            itemBuilder: (context, index) {
              final espece = especes[index];
              final isSelected = _selectedFilter == espece || (_selectedFilter == 'Tous' && espece == l10n.all);

              return Padding(
                padding: EdgeInsets.only(right: index < especes.length - 1 ? AppTheme.spacingSmall : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = espece == l10n.all ? 'Tous' : espece),
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
                    child: Text(
                      espece,
                      style: AppTheme.bodyTextLight.copyWith(
                        color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimalList(AppLocalizations l10n) {
    return Consumer<AnimalProvider>(
      builder: (context, animalProvider, child) {
        List<Animal> animaux = _selectedFilter == 'Tous'
            ? animalProvider.animaux
            : animalProvider.filtrerParEspece(_selectedFilter);

        if (_searchQuery.isNotEmpty) {
          animaux = animaux.where((animal) {
            final query = _searchQuery.toLowerCase();
            return animal.nom.toLowerCase().contains(query) ||
                animal.espece.toLowerCase().contains(query) ||
                animal.race.toLowerCase().contains(query);
          }).toList();
        }

        if (animaux.isEmpty) {
          return Center(
            child: CustomCard(
              margin: EdgeInsets.all(AppTheme.spacingXLarge),
              padding: EdgeInsets.all(AppTheme.spacingXXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.pets_outlined, size: 64, color: AppTheme.primaryPurple),
                   SizedBox(height: 16),
                   Text(l10n.noData, style: AppTheme.sectionTitle),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryPurple,
          onRefresh: () async {
            animalProvider.chargerAnimaux();
          },
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(AppTheme.spacingXLarge, 0, AppTheme.spacingXLarge, 100),
            itemCount: animaux.length,
            itemBuilder: (context, index) {
              final animal = animaux[index];
              return _ModernAnimalCard(animal: animal);
            },
          ),
        );
      },
    );
  }

  void _navigateToAddAnimal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnimalFormScreen(),
      ),
    );
  }
}

class _ModernAnimalCard extends StatelessWidget {
  final Animal animal;

  const _ModernAnimalCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: CustomCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimalDetailScreen(animalId: animal.id),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: animal.photoBase64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      child: Image.memory(
                        base64Decode(animal.photoBase64!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.pets, color: AppTheme.primaryPurple),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(animal.nom, style: AppTheme.listItemTitle),
                   Text('${animal.espece} • ${animal.race}', style: AppTheme.listItemSubtitle),
                   SizedBox(height: 4),
                   Row(
                     children: [
                       Text(animal.ageFormate, style: AppTheme.bodyTextSecondary),
                       if (animal.statut != 'Actif') ...[
                         SizedBox(width: AppTheme.spacingSmall),
                         Container(
                           padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: 2),
                           decoration: BoxDecoration(
                             color: _statutColor(animal.statut).withValues(alpha: 0.12),
                             borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                           ),
                           child: Text(
                             animal.statut,
                             style: AppTheme.bodyTextLight.copyWith(
                               color: _statutColor(animal.statut),
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       ],
                     ],
                   ),
                ],
              ),
            ),
             Icon(Icons.chevron_right, color: AppTheme.textSecondaryOf(context)),
          ],
        ),
      ),
    );
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'Vendu': return AppTheme.infoBlue;
      case 'Mort': return AppTheme.errorRed;
      case 'Réformé': return AppTheme.warningOrange;
      default: return AppTheme.successGreen;
    }
  }
}
