import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/animal_provider.dart';
import '../providers/rappel_provider.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/widgets.dart';
import 'animal/animal_list_screen.dart';
import 'feeding/feeding_list_screen.dart';
import 'health/health_list_screen.dart';
import 'reminders/reminder_list_screen.dart';
import 'statistics/statistics_screen.dart';
import 'settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? initialFilter;

  const DashboardScreen({super.key, this.initialFilter});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? _animalFilter;

  @override
  void initState() {
    super.initState();
    _animalFilter = widget.initialFilter;
    if (_animalFilter != null) {
      _selectedIndex = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimalProvider>().chargerAnimaux();
      context.read<RappelProvider>().chargerRappels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_selectedIndex),
          index: _selectedIndex,
          children: [
            const _AccueilTab(),
            AnimalListScreen(initialFilter: _animalFilter),
            const ReminderListScreen(),
            const StatisticsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: AppTheme.spacingXLarge,
              offset: Offset(0, -AppTheme.spacingXSmall),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Accueil'),
                _buildNavItem(1, Icons.pets_outlined, Icons.pets, 'Animaux'),
                _buildNavItem(2, Icons.notifications_outlined, Icons.notifications, 'Tâches'),
                _buildNavItem(3, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Stats'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightPurple.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryPurple : AppTheme.textLightOf(context),
              size: AppTheme.iconSizeMedium,
            ),
            if (isSelected) ...[
              SizedBox(width: AppTheme.spacingSmall),
              Text(
                label,
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccueilTab extends StatefulWidget {
  const _AccueilTab();

  @override
  State<_AccueilTab> createState() => _AccueilTabState();
}

class _AccueilTabState extends State<_AccueilTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryPurple,
          onRefresh: () async {
            context.read<AnimalProvider>().chargerAnimaux();
            context.read<RappelProvider>().chargerRappels();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: AppTheme.spacingMedium),
                _buildDateSelector(),
                SizedBox(height: AppTheme.spacingLarge),
                _buildStatistiquesRapides(context),
                SizedBox(height: AppTheme.spacingLarge),
                _buildTachesEnCours(context),
                SizedBox(height: AppTheme.spacingLarge),
                _buildGroupesAnimaux(context),
                SizedBox(height: AppTheme.spacingXXLarge * 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingXLarge, AppTheme.spacingSmall, AppTheme.spacingXLarge, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour',
                style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondaryOf(context)),
              ),
              SizedBox(height: AppTheme.spacingXSmall),
              Text(
                'umuragizi',
                style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
              ),
            ],
          ),
          Row(
            children: [
              IconButtonCircle(
                icon: Icons.restaurant_menu,
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const FeedingListScreen()),
                  );
                },
              ),
              SizedBox(width: AppTheme.spacingMedium),
              IconButtonCircle(
                icon: Icons.favorite_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const HealthListScreen()),
                  );
                },
              ),
              SizedBox(width: AppTheme.spacingMedium),
              IconButtonCircle(
                icon: Icons.settings_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    ScalePageRoute(page: const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Consumer<RappelProvider>(
      builder: (context, rappelProvider, child) {
        final datesWithTasks = rappelProvider.rappels
            .where((r) => !r.estComplete)
            .map((r) => r.dateRappel)
            .toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
          child: Column(
            children: [
              MonthYearHeader(
                date: _selectedDate,
                onTap: () async {
                  final date = await CustomDatePicker.show(
                    context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    title: 'Sélectionner une date',
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              SizedBox(height: AppTheme.spacingSmall),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: HorizontalDateSelector(
                  key: ValueKey<String>('${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                  selectedDate: _selectedDate,
                  datesWithTasks: datesWithTasks,
                  onDateSelected: (date) {
                    setState(() => _selectedDate = date);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatistiquesRapides(BuildContext context) {
    return Consumer2<AnimalProvider, RappelProvider>(
      builder: (context, animalProvider, rappelProvider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vue d\'ensemble',
                style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
              ),
              SizedBox(height: AppTheme.spacingMedium),
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  // Petit écran: 2 colonnes, moyen/grand: 3 colonnes max
                  final crossAxisCount = screenWidth < 400 ? 2 : 3;
                  // Ratio adapté selon le nombre de colonnes
                  final aspectRatio = crossAxisCount == 2 ? 1.4 : 1.2;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppTheme.spacingMedium,
                    mainAxisSpacing: AppTheme.spacingMedium,
                    childAspectRatio: aspectRatio,
                    children: [
                      _ModernStatCard(
                        icon: Icons.pets_rounded,
                        label: 'Animaux',
                        value: '${animalProvider.nombreAnimaux}',
                        color: AppTheme.primaryGreen,
                      ),
                      _ModernStatCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'En retard',
                        value: '${rappelProvider.nombreRappelsEnRetard}',
                        color: AppTheme.errorRed,
                      ),
                      _ModernStatCard(
                        icon: Icons.today_rounded,
                        label: 'Aujourd\'hui',
                        value: '${rappelProvider.nombreRappelsDuJour}',
                        color: AppTheme.warningOrange,
                      ),
                      _ModernStatCard(
                        icon: Icons.check_circle_rounded,
                        label: 'Complétés',
                        value: '${rappelProvider.rappels.where((r) => r.estComplete).length}',
                        color: AppTheme.primaryPurple,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTachesEnCours(BuildContext context) {
    return Consumer<RappelProvider>(
      builder: (context, rappelProvider, child) {
        final rappelsEnRetard = rappelProvider.rappelsEnRetard;
        final rappelsDuJour = rappelProvider.rappelsDuJour;
        
        // Filtrer les rappels par date sélectionnée
        final rappelsFiltres = rappelProvider.rappels.where((r) {
          if (r.estComplete) return false;
          return r.dateRappel.year == _selectedDate.year &&
                 r.dateRappel.month == _selectedDate.month &&
                 r.dateRappel.day == _selectedDate.day;
        }).toList();
        
        final isToday = _selectedDate.year == DateTime.now().year &&
                        _selectedDate.month == DateTime.now().month &&
                        _selectedDate.day == DateTime.now().day;
        
        final tousLesRappels = isToday ? [...rappelsEnRetard, ...rappelsDuJour] : rappelsFiltres;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isToday ? 'Tâches en cours' : 'Tâches du ${DateFormat('d MMM', 'fr_FR').format(_selectedDate)}',
                    style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                  ),
                  if (tousLesRappels.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(initialFilter: 'Tous'),
                          ),
                        );
                      },
                      child: const Text('Voir tout'),
                    ),
                ],
              ),
              SizedBox(height: AppTheme.spacingMedium),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: tousLesRappels.isEmpty
                    ? CustomCard(
                        key: const ValueKey('empty'),
                        padding: EdgeInsets.all(AppTheme.spacingXXLarge),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppTheme.spacingLarge),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  size: AppTheme.iconSizeXLarge,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacingLarge),
                              Text(
                                isToday ? 'Tout est à jour !' : 'Aucune tâche',
                                style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                              ),
                              SizedBox(height: AppTheme.spacingXSmall),
                              Text(
                                isToday ? 'Aucune tâche urgente' : 'Aucune tâche pour cette date',
                                style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        key: ValueKey('tasks-${tousLesRappels.length}'),
                        children: tousLesRappels.take(3).map((rappel) => _ModernRappelCard(rappel: rappel)).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupesAnimaux(BuildContext context) {
    return Consumer<AnimalProvider>(
      builder: (context, animalProvider, child) {
        final especes = animalProvider.especes;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Groupes d\'animaux',
                    style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(initialFilter: 'Tous'),
                        ),
                      );
                    },
                    child: Text('Voir tout', style: AppTheme.bodyText.copyWith(color: AppTheme.primaryPurple)),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingMedium),
              if (especes.isEmpty)
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
                            Icons.pets_outlined,
                            size: AppTheme.iconSizeXLarge,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingLarge),
                        Text(
                          'Aucun animal',
                          style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                        ),
                        SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          'Commencez par ajouter un animal',
                          style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                        ),
                        SizedBox(height: AppTheme.spacingLarge),
                        PrimaryButton(
                          text: 'Ajouter un animal',
                          icon: Icons.add,
                          width: 200,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    // Petit écran: 2 colonnes, moyen/grand: 3 colonnes
                    final crossAxisCount = screenWidth < 400 ? 2 : 3;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppTheme.spacingSmall,
                        mainAxisSpacing: AppTheme.spacingSmall,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: especes.length > 6 ? 6 : especes.length,
                      itemBuilder: (context, index) {
                        final espece = especes[index];
                        final count = animalProvider.filtrerParEspece(espece).length;
                        return _GroupeCard(
                          espece: espece,
                          count: count,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(initialFilter: espece),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ModernRappelCard extends StatelessWidget {
  final Rappel rappel;

  const _ModernRappelCard({required this.rappel});

  @override
  Widget build(BuildContext context) {
    final isEnRetard = rappel.estEnRetard;
    final tagColor = isEnRetard ? AppTheme.errorRed : AppTheme.warningOrange;

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: TaskCard(
        title: rappel.titre,
        subtitle: rappel.description,
        tag: isEnRetard ? 'En retard' : "Aujourd'hui",
        tagColor: tagColor,
        onComplete: () {
          context.read<RappelProvider>().marquerComplete(rappel.id);
        },
        trailing: Container(
          padding: EdgeInsets.all(AppTheme.spacingSmall),
          decoration: BoxDecoration(
            color: _getColorForType(rappel.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            _getIconForType(rappel.type),
            color: _getColorForType(rappel.type),
            size: AppTheme.iconSizeMedium,
          ),
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

class _GroupeCard extends StatelessWidget {
  final String espece;
  final int count;
  final VoidCallback? onTap;

  const _GroupeCard({
    required this.espece,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingSmall),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: _getColorForEspece(espece).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                _getIconForEspece(espece),
                color: _getColorForEspece(espece),
                size: AppTheme.iconSizeMedium,
              ),
            ),
            SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    espece,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                  ),
                  Text(
                    '$count',
                    style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForEspece(String espece) {
    switch (espece.toLowerCase()) {
      case 'bovin':
        return Icons.pets;
      case 'ovin':
        return Icons.cloud;
      case 'caprin':
        return Icons.terrain;
      case 'porcin':
        return Icons.cruelty_free;
      case 'volaille':
        return Icons.flutter_dash;
      case 'équin':
        return Icons.sports_handball;
      case 'lapin':
        return Icons.cruelty_free;
      default:
        return Icons.pets;
    }
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

class _ModernStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ModernStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: AppTheme.spacingSmall,
            offset: Offset(0, AppTheme.spacingXSmall),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppTheme.iconSizeMedium,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTheme.sectionTitle.copyWith(color: color),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingSmall),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
          ),
        ],
      ),
    );
  }
}
