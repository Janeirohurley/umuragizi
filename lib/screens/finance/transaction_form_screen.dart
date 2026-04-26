import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/currency_helper.dart';
import '../../services/currency_service.dart';
import '../../widgets/widgets.dart';

String categorieLabel(String dbValue, AppLocalizations l10n) {
  switch (dbValue) {
    case 'Alimentation': return l10n.catFood;
    case 'Frais Vétérinaires': return l10n.catVet;
    case 'Matériel': return l10n.catEquipment;
    case 'Achat animal': return l10n.catAnimalBuy;
    case 'Soin et Cosmétique': return l10n.catCare;
    case 'Autre Dépense': return l10n.catOtherExpense;
    case 'Vente animal': return l10n.catAnimalSale;
    case 'Lait': return l10n.catMilk;
    case 'Viande': return l10n.catMeat;
    case 'Subvention': return l10n.catSubsidy;
    case 'Autre Revenu': return l10n.catOtherRevenue;
    default: return dbValue;
  }
}

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  final Animal? animalLie;

  const TransactionFormScreen({
    super.key,
    this.transaction,
    this.animalLie,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'Dépense';
  String _categorie = 'Alimentation';
  late DateTime _date;

  final List<String> _categoriesDepenseDb = [
    'Alimentation', 'Frais Vétérinaires', 'Matériel',
    'Achat animal', 'Soin et Cosmétique', 'Autre Dépense',
  ];
  final List<String> _categoriesRevenuDb = [
    'Vente animal', 'Lait', 'Viande', 'Subvention', 'Autre Revenu',
  ];

  String _categorieLabel(String dbValue, AppLocalizations l10n) =>
      categorieLabel(dbValue, l10n);

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _categorie = widget.transaction!.categorie;
      
      // Convertir le montant de base (USD) vers la devise d'affichage pour l'édition
      final displayAmount = CurrencyHelper.convert(widget.transaction!.montant, settings.currency);
      _montantController.text = displayAmount.toStringAsFixed(settings.currency == 'BIF' ? 0 : 2);
      
      _descriptionController.text = widget.transaction!.description ?? '';
      _date = widget.transaction!.date;
    } else {
      _date = DateTime.now();
      _type = 'Dépense';
      _categorie = 'Alimentation';
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await CustomDatePicker.show(
      context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      title: AppLocalizations.of(context)!.date,
    );
    if (date != null) {
      setState(() => _date = date);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final settings = context.read<SettingsProvider>();
      final montantStr = _montantController.text.replaceAll(',', '.');
      final inputAmount = double.tryParse(montantStr) ?? 0.0;
      
      if (inputAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.invalidAmount)),
        );
        return;
      }

      // Convertir le montant saisi vers la devise de base (USD) pour le stockage
      // amount_base = amount_input / rate
      final rate = CurrencyService.rates[settings.currency] ?? 1.0;
      final amountInBase = inputAmount / rate;

      final transaction = Transaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        type: _type,
        montant: amountInBase,
        date: _date,
        categorie: _categorie,
        animalId: widget.animalLie?.id ?? widget.transaction?.animalId,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      if (widget.transaction == null) {
        context.read<FinanceProvider>().ajouterTransaction(transaction);
      } else {
        context.read<FinanceProvider>().modifierTransaction(transaction);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    List<String> categoriesDb = _type == 'Dépense' ? _categoriesDepenseDb : _categoriesRevenuDb;
    if (!categoriesDb.contains(_categorie)) {
      _categorie = categoriesDb.first;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? l10n.newTransaction : l10n.editTransaction,
          style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimaryOf(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacingXLarge),
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = 'Revenu'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                      decoration: BoxDecoration(
                        color: _type == 'Revenu' 
                            ? AppTheme.successGreen.withValues(alpha: 0.15) 
                            : AppTheme.surfaceColorOf(context),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: _type == 'Revenu' ? AppTheme.successGreen : Colors.transparent, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(l10n.revenues, style: AppTheme.sectionTitle.copyWith(color: _type == 'Revenu' ? AppTheme.successGreen : AppTheme.textSecondaryOf(context))),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = 'Dépense'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                      decoration: BoxDecoration(
                        color: _type == 'Dépense' 
                            ? AppTheme.errorRed.withValues(alpha: 0.15) 
                            : AppTheme.surfaceColorOf(context),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: _type == 'Dépense' ? AppTheme.errorRed : Colors.transparent, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(l10n.expenses, style: AppTheme.sectionTitle.copyWith(color: _type == 'Dépense' ? AppTheme.errorRed : AppTheme.textSecondaryOf(context))),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppTheme.spacingLarge),
            Text(l10n.currency, style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingSmall),
            TextFormField(
              controller: _montantController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context), fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '${settings.currencySymbol} ',
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return l10n.noData;
                return null;
              },
            ),

            SizedBox(height: AppTheme.spacingLarge),
            Text(l10n.category, style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingSmall),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categorie,
                  isExpanded: true,
                  items: categoriesDb.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(_categorieLabel(cat, l10n), style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context))),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _categorie = val!),
                ),
              ),
            ),
            
            SizedBox(height: AppTheme.spacingLarge),
            Text(l10n.date, style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingSmall),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium + 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Text(
                        '${_date.day.toString().padLeft(2, '0')} ${settings.monthName(_date.month)} ${_date.year}',
                        style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppTheme.spacingLarge),
            Text(l10n.notesOptional, style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingSmall),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context)),
              decoration: InputDecoration(
                hintText: '...',
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
            PrimaryButton(
              text: widget.transaction == null ? l10n.add : l10n.save,
              icon: Icons.check,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
