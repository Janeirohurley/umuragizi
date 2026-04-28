import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/finance_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

class ProductionFormScreen extends StatefulWidget {
  final String animalId;
  final String espece;
  final Production? production;

  const ProductionFormScreen({
    super.key,
    required this.animalId,
    required this.espece,
    this.production,
  });

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();
  final _notesController = TextEditingController();
  final _autreTypeController = TextEditingController();

  late String _type;
  late String _unite;
  DateTime _date = DateTime.now();
  String? _productionId;
  String? _ancienneTransactionId;

  static const Map<String, List<String>> _typeParEspece = {
    'bovin': ['Lait', 'Viande', 'Autre'],
    'caprin': ['Lait', 'Viande', 'Autre'],
    'ovin': ['Laine', 'Lait', 'Viande', 'Autre'],
    'volaille': ['Oeufs', 'Viande', 'Autre'],
    'porcin': ['Viande', 'Autre'],
    'lapin': ['Viande', 'Autre'],
  };

  // Âge minimum en mois pour chaque type de production par espèce
  static const Map<String, Map<String, int>> _ageMinProduction = {
    'bovin': {'Lait': 24, 'Viande': 18, 'Autre': 0},
    'caprin': {'Lait': 12, 'Viande': 12, 'Autre': 0},
    'ovin': {'Lait': 12, 'Laine': 12, 'Viande': 12, 'Autre': 0},
    'volaille': {'Oeufs': 5, 'Viande': 3, 'Autre': 0},
    'porcin': {'Viande': 6, 'Autre': 0},
    'lapin': {'Viande': 4, 'Autre': 0},
  };

  static const Map<String, String> _uniteParType = {
    'Lait': 'L',
    'Oeufs': 'unités',
    'Laine': 'kg',
    'Viande': 'kg',
    'Autre': 'kg',
  };

  List<String> get _typesDisponibles {
    final espece = widget.espece.toLowerCase();
    for (final key in _typeParEspece.keys) {
      if (espece.contains(key)) return _typeParEspece[key]!;
    }
    return ['Lait', 'Oeufs', 'Laine', 'Autre'];
  }

  @override
  void initState() {
    super.initState();
    if (widget.production != null) {
      final p = widget.production!;
      _productionId = p.id;
      _type = p.type;
      _unite = p.unite;
      _quantiteController.text = p.quantite.toString();
      _prixController.text = p.prixUnitaire?.toString() ?? '';
      _notesController.text = p.notes ?? '';
      _date = p.date;
      _ancienneTransactionId = p.transactionId;
    } else {
      _type = _typesDisponibles.first;
      _unite = _uniteParType[_type] ?? 'kg';
    }
  }

  @override
  void dispose() {
    _quantiteController.dispose();
    _prixController.dispose();
    _notesController.dispose();
    _autreTypeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final l10n = AppLocalizations.of(context)!;
    final date = await CustomDatePicker.show(
      context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      title: l10n.birthDate,
    );
    if (date != null) setState(() => _date = date);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier l'âge minimum
    final animal = DatabaseService.getAnimal(widget.animalId);
    if (animal != null) {
      final ageMin = _getAgeMinimum();
      if (ageMin > 0 && animal.ageEnMois < ageMin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cet animal est trop jeune pour ce type de production.\n'
              'Âge actuel : ${animal.ageFormate} — Minimum requis : '
              '${ageMin < 12 ? '$ageMin mois' : '${ageMin ~/ 12} an${ageMin ~/ 12 > 1 ? 's' : ''}'}.',
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          ),
        );
        return;
      }
    }
    final quantite = double.parse(_quantiteController.text);
    final prix = _prixController.text.isEmpty
        ? null
        : double.parse(_prixController.text);

    if (_ancienneTransactionId != null) {
      DatabaseService.supprimerTransaction(_ancienneTransactionId!);
    }

    String? nouvelleTransactionId;
    if (prix != null && prix > 0) {
      nouvelleTransactionId = const Uuid().v4();
      DatabaseService.ajouterTransaction(Transaction(
        id: nouvelleTransactionId,
        type: 'Revenu',
        montant: prix * quantite,
        date: _date,
        categorie: 'Production',
        animalId: widget.animalId,
        description: _type == 'Autre' && _autreTypeController.text.isNotEmpty
            ? '${_autreTypeController.text} - ${quantite.toStringAsFixed(1)} $_unite'
            : '$_type - ${quantite.toStringAsFixed(1)} $_unite',
      ));
      context.read<FinanceProvider>().chargerTransactions();
    }

    final production = Production(
      id: _productionId ?? const Uuid().v4(),
      animalId: widget.animalId,
      date: _date,
      type: _type,
      quantite: quantite,
      unite: _unite,
      prixUnitaire: prix,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      transactionId: nouvelleTransactionId,
    );

    if (_productionId != null) {
      DatabaseService.modifierProduction(production);
    } else {
      DatabaseService.ajouterProduction(production);
    }
    Navigator.pop(context);
  }

  int _getAgeMinimum() {
    final espece = widget.espece.toLowerCase();
    for (final key in _ageMinProduction.keys) {
      if (espece.contains(key)) {
        return _ageMinProduction[key]![_type] ?? 0;
      }
    }
    return 0;
  }

  String _productionTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'Lait':
        return l10n.prodMilk;
      case 'Oeufs':
        return l10n.prodEggs;
      case 'Laine':
        return l10n.prodWool;
      case 'Viande':
        return l10n.catMeat;
      case 'Autre':
        return l10n.prodOther;
      default:
        return type;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Lait':
        return Icons.water_drop;
      case 'Oeufs':
        return Icons.egg;
      case 'Laine':
        return Icons.texture;
      case 'Viande':
        return Icons.set_meal;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
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
            child: Icon(Icons.arrow_back,
                color: AppTheme.textPrimaryOf(context),
                size: AppTheme.iconSizeMedium),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _productionId == null ? l10n.addProduction : l10n.editProduction,
          style: AppTheme.pageTitle
              .copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacingXLarge),
          children: [
            Text(l10n.productionType,
                style: AppTheme.sectionTitle
                    .copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            Wrap(
              spacing: AppTheme.spacingSmall,
              runSpacing: AppTheme.spacingSmall,
              children: _typesDisponibles.map((t) {
                final isSelected = _type == t;
                return GestureDetector(
                  onTap: () => setState(() {
                    _type = t;
                    _unite = _uniteParType[t] ?? 'kg';
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryPurple
                          : AppTheme.surfaceColorOf(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_iconForType(t),
                            color: isSelected
                                ? Colors.white
                                : AppTheme.primaryPurple,
                            size: 14),
                        const SizedBox(width: 4),
                        Text(_productionTypeLabel(t, l10n),
                            style: AppTheme.bodyTextSecondary.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondaryOf(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_type == 'Autre') ...[
              SizedBox(height: AppTheme.spacingMedium),
              TextFormField(
                controller: _autreTypeController,
                style: AppTheme.formInput
                    .copyWith(color: AppTheme.textPrimaryOf(context)),
                decoration: InputDecoration(
                  hintText: l10n.description,
                  hintStyle: AppTheme.formHint,
                  prefixIcon: Icon(Icons.edit_outlined,
                      color: AppTheme.textSecondaryOf(context),
                      size: AppTheme.iconSizeMedium),
                  filled: true,
                  fillColor: AppTheme.surfaceColorOf(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => _type == 'Autre' && (v?.isEmpty ?? true)
                    ? l10n.required
                    : null,
              ),
            ],
            SizedBox(height: AppTheme.spacingXLarge),

            // Avertissement âge
            Builder(builder: (context) {
              final animal = DatabaseService.getAnimal(widget.animalId);
              final ageMin = _getAgeMinimum();
              if (animal == null || ageMin == 0 || animal.ageEnMois >= ageMin) {
                return const SizedBox.shrink();
              }
              final minLabel = ageMin < 12
                  ? '$ageMin mois'
                  : '${ageMin ~/ 12} an${ageMin ~/ 12 > 1 ? 's' : ''}';
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                      color: AppTheme.warningOrange.withValues(alpha: 0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.warningOrange, size: 20),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      '${animal.nom} a ${animal.ageFormate}. L\'âge minimum recommandé pour "$_type" est $minLabel.',
                      style: AppTheme.bodyTextLight
                          .copyWith(color: AppTheme.warningOrange),
                    ),
                  ),
                ]),
              );
            }),

            Text(l10n.quantity,
                style: AppTheme.sectionTitle
                    .copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _quantiteController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.formInput
                        .copyWith(color: AppTheme.textPrimaryOf(context)),
                    decoration: InputDecoration(
                      hintText: l10n.quantity,
                      hintStyle: AppTheme.formHint,
                      filled: true,
                      fillColor: AppTheme.surfaceColorOf(context),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                  ),
                ),
                SizedBox(width: AppTheme.spacingMedium),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLarge,
                      vertical: AppTheme.spacingMedium + 4),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPurple,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(_unite,
                      style: AppTheme.bodyText.copyWith(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingLarge),

            Text(l10n.unitPriceRevenue,
                style: AppTheme.sectionTitle
                    .copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            TextFormField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              style: AppTheme.formInput
                  .copyWith(color: AppTheme.textPrimaryOf(context)),
              decoration: InputDecoration(
                hintText: l10n.pricePerUnit,
                hintStyle: AppTheme.formHint,
                prefixIcon: Icon(Icons.attach_money,
                    color: AppTheme.textSecondaryOf(context),
                    size: AppTheme.iconSizeMedium),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),

            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: AppTheme.primaryPurple,
                        size: AppTheme.iconSizeMedium),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Text(
                        '${_date.day.toString().padLeft(2, '0')} ${settings.monthName(_date.month)} ${_date.year}',
                        style: AppTheme.listItemTitle
                            .copyWith(color: AppTheme.textPrimaryOf(context)),
                      ),
                    ),
                    Icon(Icons.edit_outlined,
                        color: AppTheme.textLightOf(context),
                        size: AppTheme.iconSizeMedium),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),

            TextFormField(
              controller: _notesController,
              maxLines: 2,
              style: AppTheme.formInput
                  .copyWith(color: AppTheme.textPrimaryOf(context)),
              decoration: InputDecoration(
                hintText: l10n.notesOptional,
                hintStyle: AppTheme.formHint,
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),
            PrimaryButton(text: l10n.save, icon: Icons.check, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
