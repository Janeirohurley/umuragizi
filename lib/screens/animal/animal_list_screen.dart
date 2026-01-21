import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppTheme.spacingLarge),
            _buildSearchBar(),
            SizedBox(height: AppTheme.spacingLarge),
            _buildFilters(),
            SizedBox(height: AppTheme.spacingLarge),
            Expanded(child: _buildAnimalList()),
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingXLarge, AppTheme.spacingLarge, AppTheme.spacingXLarge, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mes Animaux',
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
                '${provider.nombreAnimaux} total',
                style: AppTheme.tagText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
            hintText: 'Rechercher un animal...',
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

  Widget _buildFilters() {
    return Consumer<AnimalProvider>(
      builder: (context, provider, _) {
        final especes = ['Tous', ...provider.especes];

        return SizedBox(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
            itemCount: especes.length,
            itemBuilder: (context, index) {
              final espece = especes[index];
              final isSelected = _selectedFilter == espece;

              return Padding(
                padding: EdgeInsets.only(right: index < especes.length - 1 ? AppTheme.spacingSmall : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = espece),
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

  Widget _buildAnimalList() {
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
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets_outlined,
                      size: AppTheme.iconSizeXLarge,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXLarge),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Aucun résultat'
                        : 'Aucun animal enregistré',
                    style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Essayez une autre recherche'
                        : 'Commencez par ajouter votre premier animal',
                    style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                    textAlign: TextAlign.center,
                  ),
                  if (_searchQuery.isEmpty) ...[
                    SizedBox(height: AppTheme.spacingXXLarge),
                    PrimaryButton(
                      text: 'Ajouter un animal',
                      icon: Icons.add,
                      width: 200,
                      onPressed: () => _navigateToAddAnimal(context),
                    ),
                  ],
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
                color: _getColorForEspece(animal.espece).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: animal.photoBase64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      child: Image.memory(
                        base64Decode(animal.photoBase64!),
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            size: AppTheme.iconSizeLarge,
                            color: _getColorForEspece(animal.espece),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      size: AppTheme.iconSizeLarge,
                      color: _getColorForEspece(animal.espece),
                    ),
            ),
            SizedBox(width: AppTheme.spacingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(animal.nom, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingXSmall),
                        decoration: BoxDecoration(
                          color: animal.sexe == 'Mâle'
                              ? AppTheme.infoBlue.withValues(alpha: 0.1)
                              : const Color(0xFFEC4899).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              animal.sexe == 'Mâle' ? Icons.male : Icons.female,
                              size: AppTheme.iconSizeSmall,
                              color: animal.sexe == 'Mâle'
                                  ? AppTheme.infoBlue
                                  : const Color(0xFFEC4899),
                            ),
                            SizedBox(width: AppTheme.spacingXSmall),
                            Text(
                              animal.sexe,
                              style: AppTheme.bodyText.copyWith(
                                fontWeight: FontWeight.w500,
                                color: animal.sexe == 'Mâle'
                                    ? AppTheme.infoBlue
                                    : const Color(0xFFEC4899),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingXSmall),
                  Text('${animal.espece} • ${animal.race}', style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                  SizedBox(height: AppTheme.spacingSmall),
                  Row(
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        size: AppTheme.iconSizeSmall,
                        color: AppTheme.textLightOf(context),
                      ),
                      SizedBox(width: AppTheme.spacingXSmall),
                      Text(animal.ageFormate, style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context))),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppTheme.spacingSmall),
            Container(
              padding: EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryOf(context),
                size: AppTheme.iconSizeMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForEspece(String espece) {
    switch (espece.toLowerCase()) {
      case 'bovin':
        return AppTheme.primaryPurple;
      case 'ovin':
        return AppTheme.infoBlue;
      case 'caprin':
        return AppTheme.accentOrange;
      case 'porcin':
        return const Color(0xFFEC4899);
      case 'volaille':
        return AppTheme.warningOrange;
      case 'équin':
        return AppTheme.successGreen;
      case 'lapin':
        return const Color(0xFF8B5CF6);
      default:
        return AppTheme.textSecondary;
    }
  }
}
