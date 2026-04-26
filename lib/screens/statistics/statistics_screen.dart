import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/animal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/age_helper.dart';
import '../../widgets/widgets.dart';
import '../animal/animal_list_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedAnimalId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animaux = context.watch<AnimalProvider>().animaux;

    if (animaux.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColorOf(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.statistics,
              style: AppTheme.pageTitle
                  .copyWith(color: AppTheme.textPrimaryOf(context))),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: AppTheme.primaryPurple),
              const SizedBox(height: 16),
              Text(l10n.noData, style: AppTheme.sectionTitle),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.statistics,
            style: AppTheme.pageTitle
                .copyWith(color: AppTheme.textPrimaryOf(context))),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPurple,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: AppTheme.textSecondaryOf(context),
          tabs: [
            Tab(text: l10n.global),
            Tab(text: l10n.byCategory),
            Tab(text: l10n.byAnimal),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalTab(l10n, animaux),
          _buildCategoryTab(l10n, animaux),
          _buildAnimalTab(l10n, animaux),
        ],
      ),
    );
  }

  // ─── ONGLET GLOBAL ───────────────────────────────────────────────────────

  Widget _buildGlobalTab(AppLocalizations l10n, List<Animal> animaux) {
    final actifs = animaux.where((a) => a.statut == 'Actif').toList();
    final males = animaux.where((a) => a.sexe == 'Mâle').length;
    final femelles = animaux.where((a) => a.sexe == 'Femelle').length;
    final especes = animaux.map((a) => a.espece).toSet().length;

    final ageMoyenMois = animaux.isEmpty
        ? 0.0
        : animaux.map((a) => a.ageEnMois).reduce((a, b) => a + b) /
            animaux.length;

    final transactions = DatabaseService.getAllTransactions();
    final revenus = transactions
        .where((t) => t.type == 'Revenu')
        .fold<double>(0, (s, t) => s + t.montant);
    final depenses = transactions
        .where((t) => t.type == 'Dépense')
        .fold<double>(0, (s, t) => s + t.montant);

    final santes = DatabaseService.getAllSantes();
    final now = DateTime.now();
    final santesCeMois = santes
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .length;

    final croissances = DatabaseService.getAllCroissances();
    final productions = DatabaseService.getAllProductions();

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
      children: [
        // ── Troupeau ──
        _SectionHeader(title: l10n.herd, icon: Icons.pets),
        const SizedBox(height: AppTheme.spacingSmall),
        Row(children: [
          Expanded(
              child: _StatTile(
                  label: l10n.total,
                  value: '${animaux.length}',
                  icon: Icons.inventory_2_outlined,
                  color: AppTheme.primaryPurple)),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
              child: _StatTile(
                  label: l10n.active,
                  value: '${actifs.length}',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.successGreen)),
        ]),
        const SizedBox(height: AppTheme.spacingSmall),
        Row(children: [
          Expanded(
              child: _StatTile(
                  label: l10n.species,
                  value: '$especes',
                  icon: Icons.category_outlined,
                  color: AppTheme.infoBlue)),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
              child: _StatTile(
                  label: l10n.avgAge,
                  value: formatAge(ageMoyenMois.round(), l10n),
                  icon: Icons.cake_outlined,
                  color: AppTheme.accentOrange)),
        ]),
        const SizedBox(height: AppTheme.spacingSmall),
        // Sex ratio
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.sexRatio,
                      style: AppTheme.cardTitle
                          .copyWith(color: AppTheme.textPrimaryOf(context))),
                  Text('$males ${l10n.male[0]} • $femelles ${l10n.female[0]}',
                      style: AppTheme.bodyTextLight.copyWith(
                          color: AppTheme.textSecondaryOf(context))),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              if (animaux.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(children: [
                    if (males > 0)
                      Expanded(
                        flex: males,
                        child: Container(
                          height: 12,
                          color: AppTheme.infoBlue,
                        ),
                      ),
                    if (femelles > 0)
                      Expanded(
                        flex: femelles,
                        child: Container(
                          height: 12,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                  ]),
                ),
              const SizedBox(height: AppTheme.spacingSmall),
              Row(children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: AppTheme.infoBlue, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('${l10n.males} ($males)',
                    style: AppTheme.bodyTextLight
                        .copyWith(color: AppTheme.textSecondaryOf(context))),
                const SizedBox(width: AppTheme.spacingMedium),
                Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: AppTheme.accentOrange, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('${l10n.females} ($femelles)',
                    style: AppTheme.bodyTextLight
                        .copyWith(color: AppTheme.textSecondaryOf(context))),
              ]),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingLarge),
        // ── Finance ──
        _SectionHeader(title: l10n.finance, icon: Icons.account_balance_wallet_outlined),
        const SizedBox(height: AppTheme.spacingSmall),
        CustomCard(
          child: Column(children: [
            _FinanceRow(label: l10n.revenues, amount: revenus, color: AppTheme.successGreen),
            const Divider(height: AppTheme.spacingLarge),
            _FinanceRow(label: l10n.expenses, amount: depenses, color: AppTheme.errorRed),
            const Divider(height: AppTheme.spacingLarge),
            _FinanceRow(
              label: l10n.balance,
              amount: revenus - depenses,
              color: (revenus - depenses) >= 0 ? AppTheme.successGreen : AppTheme.errorRed,
              bold: true,
            ),
          ]),
        ),

        const SizedBox(height: AppTheme.spacingLarge),
        // ── Santé ──
        _SectionHeader(title: l10n.healthCare, icon: Icons.favorite_outline),
        const SizedBox(height: AppTheme.spacingSmall),
        Row(children: [
          Expanded(
              child: _StatTile(
                  label: l10n.totalCare,
                  value: '${santes.length}',
                  icon: Icons.medical_services_outlined,
                  color: AppTheme.errorRed)),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
              child: _StatTile(
                  label: l10n.thisMonth,
                  value: '$santesCeMois',
                  icon: Icons.calendar_today_outlined,
                  color: AppTheme.warningOrange)),
        ]),
        if (santes.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingSmall),
          _buildSanteTypesCard(santes, l10n),
        ],
        if (productions.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingLarge),
          _SectionHeader(title: l10n.production, icon: Icons.factory_outlined),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildProductionCard(productions, l10n),
        ],
        if (croissances.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingLarge),
          _SectionHeader(title: l10n.growth, icon: Icons.trending_up),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildCroissanceGlobaleCard(croissances, l10n),
        ],
        const SizedBox(height: AppTheme.spacingLarge),
        _SectionHeader(title: l10n.bySpecies, icon: Icons.pie_chart_outline),
        const SizedBox(height: AppTheme.spacingSmall),
        CustomCard(
          child: SizedBox(
            height: 220,
            child: _buildPieChart(animaux, l10n),
          ),
        ),
        const SizedBox(height: AppTheme.spacingXXLarge),
      ],
    );
  }

  Widget _buildSanteTypesCard(List<Sante> santes, AppLocalizations l10n) {
    final byType = <String, int>{};
    for (final s in santes) { byType[s.type] = (byType[s.type] ?? 0) + 1; }
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.careByType, style: AppTheme.cardTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
          const SizedBox(height: AppTheme.spacingMedium),
          ...byType.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key,
                        style: AppTheme.bodyText.copyWith(
                            color: AppTheme.textPrimaryOf(context))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingXSmall),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Text('${e.value}',
                          style: AppTheme.bodyTextLight.copyWith(
                              color: AppTheme.errorRed,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProductionCard(List<Production> productions, AppLocalizations l10n) {
    final byType = <String, double>{};
    for (final p in productions) { byType[p.type] = (byType[p.type] ?? 0) + p.quantite; }
    final colors = [AppTheme.primaryPurple, AppTheme.infoBlue, AppTheme.successGreen, AppTheme.accentOrange];
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.productionTotals, style: AppTheme.cardTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
          const SizedBox(height: AppTheme.spacingMedium),
          ...byType.entries.toList().asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final color = colors[i % colors.length];
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppTheme.spacingSmall),
              child: Row(
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                      child: Text(e.key,
                          style: AppTheme.bodyText.copyWith(
                              color: AppTheme.textPrimaryOf(context)))),
                  Text(
                      '${e.value % 1 == 0 ? e.value.toInt() : e.value.toStringAsFixed(1)}',
                      style: AppTheme.bodyText.copyWith(
                          color: color, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCroissanceGlobaleCard(List<Croissance> croissances, AppLocalizations l10n) {
    if (croissances.isEmpty) return const SizedBox.shrink();
    final poids = croissances.map((c) => c.poids).toList();
    final poidsMax = poids.reduce((a, b) => a > b ? a : b);
    final poidsMoyen = poids.reduce((a, b) => a + b) / poids.length;
    return CustomCard(
      child: Row(children: [
        Expanded(child: _StatTile(label: l10n.weightMax, value: '${poidsMax.toStringAsFixed(1)} kg', icon: Icons.arrow_upward, color: AppTheme.successGreen)),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(child: _StatTile(label: l10n.weightAvg, value: '${poidsMoyen.toStringAsFixed(1)} kg', icon: Icons.straighten, color: AppTheme.infoBlue)),
      ]),
    );
  }

  Widget _buildPieChart(List<Animal> animaux, AppLocalizations l10n) {
    final counts = <String, int>{};
    for (final a in animaux) {
      counts[a.espece] = (counts[a.espece] ?? 0) + 1;
    }
    final total = animaux.length;
    final colors = [
      AppTheme.primaryPurple,
      AppTheme.infoBlue,
      AppTheme.successGreen,
      AppTheme.accentOrange,
      AppTheme.errorRed,
      AppTheme.warningOrange,
    ];
    final entries = counts.entries.toList();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: entries.asMap().entries.map((e) {
                final color = colors[e.key % colors.length];
                final pct = (e.value.value / total * 100).toStringAsFixed(0);
                return PieChartSectionData(
                  value: e.value.value.toDouble(),
                  title: '$pct%',
                  color: color,
                  radius: 55,
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.asMap().entries.map((e) {
              final color = colors[e.key % colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${especeLabel(e.value.key, l10n)} (${e.value.value})',
                      style: AppTheme.bodyTextLight.copyWith(
                          color: AppTheme.textPrimaryOf(context),
                          fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── ONGLET PAR CATÉGORIE ────────────────────────────────────────────────

  Widget _buildCategoryTab(AppLocalizations l10n, List<Animal> animaux) {
    final speciesMap = <String, List<Animal>>{};
    for (final a in animaux) {
      speciesMap.putIfAbsent(a.espece, () => []).add(a);
    }

    final allSantes = DatabaseService.getAllSantes();
    final allProductions = DatabaseService.getAllProductions();
    final allCroissances = DatabaseService.getAllCroissances();
    final allTransactions = DatabaseService.getAllTransactions();

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
      children: speciesMap.entries.map((entry) {
        final espece = entry.key;
        final animals = entry.value;
        final ids = animals.map((a) => a.id).toSet();

        final actifs = animals.where((a) => a.statut == 'Actif').length;
        final males = animals.where((a) => a.sexe == 'Mâle').length;
        final femelles = animals.where((a) => a.sexe == 'Femelle').length;

        final santesEspece =
            allSantes.where((s) => ids.contains(s.animalId)).toList();
        final prodEspece =
            allProductions.where((p) => ids.contains(p.animalId)).toList();
        final croissEspece =
            allCroissances.where((c) => ids.contains(c.animalId)).toList();
        final txEspece =
            allTransactions.where((t) => ids.contains(t.animalId)).toList();

        final revenus = txEspece
            .where((t) => t.type == 'Revenu')
            .fold<double>(0, (s, t) => s + t.montant);
        final depenses = txEspece
            .where((t) => t.type == 'Dépense')
            .fold<double>(0, (s, t) => s + t.montant);

        final poidsMoyen = croissEspece.isEmpty
            ? null
            : croissEspece.map((c) => c.poids).reduce((a, b) => a + b) /
                croissEspece.length;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header espèce
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(especeLabel(espece, l10n),
                        style: AppTheme.sectionTitle.copyWith(
                            color: AppTheme.textPrimaryOf(context))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Text('$actifs ${l10n.active} / ${animals.length}',
                          style: AppTheme.bodyTextLight.copyWith(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // Sexes
                Row(children: [
                  Icon(Icons.male, size: 16, color: AppTheme.infoBlue),
                  const SizedBox(width: 4),
                  Text('$males ${l10n.males.toLowerCase()}',
                      style: AppTheme.bodyTextLight.copyWith(
                          color: AppTheme.textSecondaryOf(context))),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Icon(Icons.female, size: 16, color: AppTheme.accentOrange),
                  const SizedBox(width: 4),
                  Text('$femelles ${l10n.females.toLowerCase()}',
                      style: AppTheme.bodyTextLight.copyWith(
                          color: AppTheme.textSecondaryOf(context))),
                ]),

                if (poidsMoyen != null) ...[
                  const SizedBox(height: AppTheme.spacingSmall),
                  Row(children: [
                    Icon(Icons.monitor_weight_outlined,
                        size: 16, color: AppTheme.successGreen),
                    const SizedBox(width: 4),
                    Text('${l10n.weightAvg} : ${poidsMoyen.toStringAsFixed(1)} kg',
                        style: AppTheme.bodyTextLight.copyWith(
                            color: AppTheme.textSecondaryOf(context))),
                  ]),
                ],

                if (santesEspece.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingSmall),
                  Row(children: [
                    Icon(Icons.medical_services_outlined,
                        size: 16, color: AppTheme.errorRed),
                    const SizedBox(width: 4),
                    Text('${santesEspece.length} ${l10n.totalCare.toLowerCase()}',
                        style: AppTheme.bodyTextLight.copyWith(
                            color: AppTheme.textSecondaryOf(context))),
                  ]),
                ],

                if (prodEspece.isNotEmpty) ...[
                  const Divider(height: AppTheme.spacingLarge),
                  Text(l10n.production,
                      style: AppTheme.bodyTextLight.copyWith(
                          color: AppTheme.textSecondaryOf(context),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.spacingSmall),
                  ..._groupProductionByType(prodEspece).entries.map((e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key,
                              style: AppTheme.bodyTextLight.copyWith(
                                  color: AppTheme.textPrimaryOf(context))),
                          Text(
                              '${e.value % 1 == 0 ? e.value.toInt() : e.value.toStringAsFixed(1)}',
                              style: AppTheme.bodyTextLight.copyWith(
                                  color: AppTheme.primaryPurple,
                                  fontWeight: FontWeight.w600)),
                        ],
                      )),
                ],

                if (revenus > 0 || depenses > 0) ...[
                  const Divider(height: AppTheme.spacingLarge),
                  Text(l10n.finance,
                      style: AppTheme.bodyTextLight.copyWith(
                          color: AppTheme.textSecondaryOf(context),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(l10n.revenues, style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textPrimaryOf(context))),
                    Text('+${revenus.toStringAsFixed(0)}', style: AppTheme.bodyTextLight.copyWith(color: AppTheme.successGreen, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(l10n.expenses, style: AppTheme.bodyTextLight.copyWith(color: AppTheme.textPrimaryOf(context))),
                    Text('-${depenses.toStringAsFixed(0)}', style: AppTheme.bodyTextLight.copyWith(color: AppTheme.errorRed, fontWeight: FontWeight.w600)),
                  ]),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── ONGLET PAR ANIMAL ───────────────────────────────────────────────────

  Widget _buildAnimalTab(AppLocalizations l10n, List<Animal> animaux) {
    if (_selectedAnimalId == null && animaux.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedAnimalId = animaux.first.id);
      });
    }

    final selected = _selectedAnimalId != null
        ? animaux.where((a) => a.id == _selectedAnimalId).firstOrNull
        : null;

    return Column(
      children: [
        // Sélecteur animal
        Container(
          margin: const EdgeInsets.fromLTRB(AppTheme.spacingXLarge,
              AppTheme.spacingMedium, AppTheme.spacingXLarge, 0),
          child: GestureDetector(
            onTap: () => _showAnimalPicker(l10n, animaux),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                  vertical: AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      AppTheme.primaryPurple.withValues(alpha: 0.15),
                  child: const Icon(Icons.pets,
                      color: AppTheme.primaryPurple, size: 18),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected?.nom ?? l10n.noData,
                        style: AppTheme.listItemTitle.copyWith(
                            color: AppTheme.textPrimaryOf(context)),
                      ),
                      if (selected != null)
                        Text(
                          '${especeLabel(selected.espece, l10n)} • ${formatAge(selected.ageEnMois, l10n)}',
                          style: AppTheme.bodyTextLight.copyWith(
                              color: AppTheme.textSecondaryOf(context)),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.expand_more,
                    color: AppTheme.textSecondaryOf(context)),
              ]),
            ),
          ),
        ),
        if (selected != null)
          Expanded(
            child: _buildAnimalDetail(selected, l10n),
          ),
      ],
    );
  }

  void _showAnimalPicker(AppLocalizations l10n, List<Animal> animaux) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.textLightOf(context),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(l10n.animals,
              style: AppTheme.bottomSheetTitle
                  .copyWith(color: AppTheme.textPrimaryOf(context))),
          const SizedBox(height: AppTheme.spacingMedium),
          Expanded(
            child: ListView(
              children: animaux
                  .map((a) => ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: (_selectedAnimalId == a.id
                                  ? AppTheme.primaryPurple
                                  : AppTheme.surfaceColorOf(context)),
                          child: Icon(Icons.pets,
                              size: 16,
                              color: _selectedAnimalId == a.id
                                  ? Colors.white
                                  : AppTheme.textSecondaryOf(context)),
                        ),
                        title: Text(a.nom,
                            style: AppTheme.listItemTitle.copyWith(
                                color: _selectedAnimalId == a.id
                                    ? AppTheme.primaryPurple
                                    : AppTheme.textPrimaryOf(context),
                                fontWeight: _selectedAnimalId == a.id
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                        subtitle: Text('${especeLabel(a.espece, l10n)} • ${formatAge(a.ageEnMois, l10n)}',
                            style: AppTheme.bodyTextLight.copyWith(
                                color:
                                    AppTheme.textSecondaryOf(context))),
                        trailing: _selectedAnimalId == a.id
                            ? const Icon(Icons.check_circle,
                                color: AppTheme.primaryPurple)
                            : null,
                        onTap: () {
                          setState(() => _selectedAnimalId = a.id);
                          Navigator.pop(ctx);
                        },
                      ))
                  .toList(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildAnimalDetail(Animal animal, AppLocalizations l10n) {
    final croissances = DatabaseService.getCroissancesParAnimal(animal.id);
    final alimentations =
        DatabaseService.getAlimentationsParAnimal(animal.id);
    final santes = DatabaseService.getSantesParAnimal(animal.id);
    final productions = DatabaseService.getAllProductions()
        .where((p) => p.animalId == animal.id)
        .toList();
    final transactions = DatabaseService.getAllTransactions()
        .where((t) => t.animalId == animal.id)
        .toList();

    final revenus = transactions
        .where((t) => t.type == 'Revenu')
        .fold<double>(0, (s, t) => s + t.montant);
    final depenses = transactions
        .where((t) => t.type == 'Dépense')
        .fold<double>(0, (s, t) => s + t.montant);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
      children: [
        // Infos de base
        Row(children: [
          Expanded(child: _StatTile(label: l10n.age, value: formatAge(animal.ageEnMois, l10n), icon: Icons.cake_outlined, color: AppTheme.primaryPurple)),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(child: _StatTile(label: l10n.status, value: statutLabel(animal.statut, l10n), icon: Icons.info_outline, color: animal.statut == 'Actif' ? AppTheme.successGreen : AppTheme.warningOrange)),
        ]),
        const SizedBox(height: AppTheme.spacingSmall),
        Row(children: [
          Expanded(child: _StatTile(label: l10n.sante, value: '${santes.length}', icon: Icons.medical_services_outlined, color: AppTheme.errorRed)),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(child: _StatTile(label: l10n.feedings, value: '${alimentations.length}', icon: Icons.restaurant_outlined, color: AppTheme.accentOrange)),
        ]),

        // Finance animal
        if (revenus > 0 || depenses > 0) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          CustomCard(
            child: Column(children: [
              _FinanceRow(label: l10n.revenues, amount: revenus, color: AppTheme.successGreen),
              const Divider(height: AppTheme.spacingMedium),
              _FinanceRow(label: l10n.expenses, amount: depenses, color: AppTheme.errorRed),
              const Divider(height: AppTheme.spacingMedium),
              _FinanceRow(label: l10n.balance,
                amount: revenus - depenses,
                color: (revenus - depenses) >= 0
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
                bold: true,
              ),
            ]),
          ),
        ],

        // Courbe poids
        if (croissances.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.weightEvolution,
                    style: AppTheme.cardTitle.copyWith(
                        color: AppTheme.textPrimaryOf(context))),
                const SizedBox(height: AppTheme.spacingMedium),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, _) => Text(
                                '${v.toInt()}kg',
                                style: AppTheme.bodyTextLight.copyWith(
                                    color:
                                        AppTheme.textSecondaryOf(context),
                                    fontSize: 10)),
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: croissances
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                  e.key.toDouble(), e.value.poids))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.primaryPurple,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryPurple
                                .withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Production animal
        if (productions.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.production,
                    style: AppTheme.cardTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                const SizedBox(height: AppTheme.spacingMedium),
                ..._groupProductionByType(productions).entries.map((e) =>
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppTheme.spacingSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key,
                              style: AppTheme.bodyText.copyWith(
                                  color:
                                      AppTheme.textPrimaryOf(context))),
                          Text(
                              '${e.value % 1 == 0 ? e.value.toInt() : e.value.toStringAsFixed(1)}',
                              style: AppTheme.bodyText.copyWith(
                                  color: AppTheme.primaryPurple,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppTheme.spacingXXLarge),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Map<String, double> _groupProductionByType(List<Production> productions) {
    final map = <String, double>{};
    for (final p in productions) {
      map[p.type] = (map[p.type] ?? 0) + p.quantite;
    }
    return map;
  }

}

// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppTheme.primaryPurple, size: 18),
      const SizedBox(width: AppTheme.spacingSmall),
      Text(title,
          style: AppTheme.sectionTitle
              .copyWith(color: AppTheme.textPrimaryOf(context))),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTheme.statValue
                      .copyWith(color: AppTheme.textPrimaryOf(context))),
              Text(label,
                  style: AppTheme.statLabel
                      .copyWith(color: AppTheme.textSecondaryOf(context))),
            ],
          ),
        ),
      ]),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool bold;

  const _FinanceRow(
      {required this.label,
      required this.amount,
      required this.color,
      this.bold = false});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsProvider>().currency;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: (bold ? AppTheme.listItemTitle : AppTheme.listItemSubtitle)
                .copyWith(color: AppTheme.textPrimaryOf(context))),
        Text('${amount.toStringAsFixed(0)} $currency',
            style: (bold ? AppTheme.listItemTitle : AppTheme.bodyTextLight)
                .copyWith(
                    color: color,
                    fontWeight:
                        bold ? FontWeight.w700 : FontWeight.normal)),
      ],
    );
  }
}
