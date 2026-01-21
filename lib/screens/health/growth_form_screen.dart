import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';

class GrowthFormScreen extends StatefulWidget {
  final String animalId;

  const GrowthFormScreen({super.key, required this.animalId});

  @override
  State<GrowthFormScreen> createState() => _GrowthFormScreenState();
}

class _GrowthFormScreenState extends State<GrowthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _poidsController = TextEditingController();
  final _tailleController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _etatPhysique = 'bon';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _poidsController.dispose();
    _tailleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
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
      setState(() => _date = date);
    }
  }

  void _showEtatBottomSheet() {
    final etats = ['excellent', 'bon', 'moyen', 'faible'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppTheme.spacingMedium),
            Container(
              width: AppTheme.spacingXXLarge,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLightOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              'État physique',
              style: AppTheme.bottomSheetTitle.copyWith(
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            ...etats.map((etat) => ListTile(
              leading: Icon(
                Icons.favorite,
                color: _etatPhysique == etat ? AppTheme.primaryPurple : AppTheme.textSecondaryOf(context),
              ),
              title: Text(
                etat[0].toUpperCase() + etat.substring(1),
                style: TextStyle(
                  fontWeight: _etatPhysique == etat ? FontWeight.w600 : FontWeight.normal,
                  color: _etatPhysique == etat ? AppTheme.primaryPurple : AppTheme.textPrimaryOf(context),
                ),
              ),
              trailing: _etatPhysique == etat
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryPurple)
                  : null,
              onTap: () {
                setState(() => _etatPhysique = etat);
                Navigator.pop(context);
              },
            )),
            SizedBox(height: AppTheme.spacingLarge),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final croissance = Croissance(
        id: const Uuid().v4(),
        animalId: widget.animalId,
        date: _date,
        poids: double.parse(_poidsController.text),
        taille: _tailleController.text.isEmpty ? null : double.parse(_tailleController.text),
        etatPhysique: _etatPhysique,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      DatabaseService.ajouterCroissance(croissance);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Ajouter mesure',
          style: AppTheme.pageTitle.copyWith(
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacingXLarge),
          children: [
            TextFormField(
              controller: _poidsController,
              decoration: InputDecoration(
                hintText: 'Poids (kg)',
                hintStyle: AppTheme.formHint,
                prefixIcon: Icon(Icons.monitor_weight, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingMedium),
              ),
              style: AppTheme.formInput,
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Le poids est requis' : null,
            ),
            SizedBox(height: AppTheme.spacingMedium),
            TextFormField(
              controller: _tailleController,
              decoration: InputDecoration(
                hintText: 'Taille (cm) - optionnel',
                hintStyle: AppTheme.formHint,
                prefixIcon: Icon(Icons.height, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingMedium),
              ),
              style: AppTheme.formInput,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppTheme.spacingMedium),
            GestureDetector(
              onTap: _showEtatBottomSheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite_outline, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Text(
                        _etatPhysique != null ? _etatPhysique![0].toUpperCase() + _etatPhysique!.substring(1) : 'État physique',
                        style: AppTheme.formInput,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppTheme.textLightOf(context)),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
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
                    Icon(Icons.calendar_today, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: AppTheme.formLabel,
                          ),
                          Text(
                            DateFormat('d MMMM yyyy', 'fr_FR').format(_date),
                            style: AppTheme.formInput.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_outlined, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeMedium),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Notes (optionnel)',
                hintStyle: AppTheme.formHint,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spacingXXLarge),
                  child: Icon(Icons.edit_note_outlined, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingMedium),
              ),
              style: AppTheme.formInput,
              maxLines: 3,
            ),
            SizedBox(height: AppTheme.spacingXXLarge),
            PrimaryButton(
              text: 'Enregistrer',
              icon: Icons.check,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
