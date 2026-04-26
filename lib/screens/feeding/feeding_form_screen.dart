import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/finance_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

class FeedingFormScreen extends StatefulWidget {
  final String animalId;
  final Alimentation? alimentation;

  const FeedingFormScreen({super.key, required this.animalId, this.alimentation});

  @override
  State<FeedingFormScreen> createState() => _FeedingFormScreenState();
}

class _FeedingFormScreenState extends State<FeedingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _prixUnitaireController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _unite = 'kg';
  DateTime _date = DateTime.now();
  String? _alimentationId;
  String? _ancienneTransactionId;

  @override
  void initState() {
    super.initState();
    if (widget.alimentation != null) {
      final a = widget.alimentation!;
      _alimentationId = a.id;
      _typeController.text = a.typeAliment;
      _quantiteController.text = a.quantite.toString();
      _prixUnitaireController.text = a.prixUnitaire?.toString() ?? '';
      _notesController.text = a.notes ?? '';
      _unite = a.unite;
      _date = a.date;
      _ancienneTransactionId = a.transactionId;
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _quantiteController.dispose();
    _prixUnitaireController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_date),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryPurple,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppTheme.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() => _date = DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final prixUnitaire = _prixUnitaireController.text.isEmpty
          ? null
          : double.parse(_prixUnitaireController.text);
      final quantite = double.parse(_quantiteController.text);

      // Supprimer l'ancienne transaction liée si elle existe
      if (_ancienneTransactionId != null) {
        DatabaseService.supprimerTransaction(_ancienneTransactionId!);
      }

      String? nouvelleTransactionId;
      if (prixUnitaire != null && prixUnitaire > 0) {
        nouvelleTransactionId = const Uuid().v4();
        final transaction = Transaction(
          id: nouvelleTransactionId,
          type: 'Dépense',
          montant: prixUnitaire * quantite,
          date: _date,
          categorie: 'Alimentation',
          animalId: widget.animalId,
          description: _typeController.text,
        );
        DatabaseService.ajouterTransaction(transaction);
        context.read<FinanceProvider>().chargerTransactions();
      }

      final alimentation = Alimentation(
        id: _alimentationId ?? const Uuid().v4(),
        animalId: widget.animalId,
        date: _date,
        typeAliment: _typeController.text,
        quantite: quantite,
        unite: _unite,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        prixUnitaire: prixUnitaire,
        transactionId: nouvelleTransactionId,
      );

      if (_alimentationId != null) {
        DatabaseService.modifierAlimentation(alimentation);
      } else {
        DatabaseService.ajouterAlimentation(alimentation);
      }
      Navigator.pop(context);
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
            child: Icon(Icons.arrow_back, color: AppTheme.textPrimaryOf(context), size: AppTheme.iconSizeMedium),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.alimentation == null ? l10n.addFeeding : l10n.editFeeding,
          style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacingXLarge),
          children: [
            TextFormField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: l10n.foodType,
                hintStyle: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                prefixIcon: Icon(Icons.restaurant, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
              ),
              validator: (v) => v?.isEmpty ?? true ? l10n.foodTypeRequired : null,
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantiteController,
                    decoration: InputDecoration(
                      hintText: l10n.quantity,
                      hintStyle: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                      prefixIcon: Icon(Icons.scale, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColorOf(context),
                      contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                  ),
                ),
                SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unite,
                    decoration: InputDecoration(
                      hintText: l10n.unit,
                      hintStyle: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColorOf(context),
                      contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
                    ),
                    items: ['kg', 'g', 'L', 'mL'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _unite = v!),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingLarge),
            TextFormField(
              controller: _prixUnitaireController,
              decoration: InputDecoration(
                hintText: l10n.unitPrice,
                hintStyle: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                prefixIcon: Icon(Icons.euro, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppTheme.spacingLarge),
            GestureDetector(
              onTap: _selectDateTime,
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dateTime,
                            style: AppTheme.bodyTextSecondary.copyWith(color: AppTheme.textSecondaryOf(context)),
                          ),
                          Text(
                            '${_date.day.toString().padLeft(2,'0')} ${settings.monthName(_date.month)} ${_date.year} à ${_date.hour.toString().padLeft(2,'0')}:${_date.minute.toString().padLeft(2,'0')}',
                            style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_outlined, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeMedium),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: l10n.notesOptional,
                hintStyle: AppTheme.bodyTextLight.copyWith(color: AppTheme.textLightOf(context)),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spacingXXLarge + AppTheme.spacingLarge),
                  child: Icon(Icons.edit_note_outlined, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
              ),
              maxLines: 3,
            ),
            SizedBox(height: AppTheme.spacingXXLarge),
            PrimaryButton(
              text: l10n.save,
              icon: Icons.check,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
