import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';

class HealthFormScreen extends StatefulWidget {
  final String animalId;

  const HealthFormScreen({super.key, required this.animalId});

  @override
  State<HealthFormScreen> createState() => _HealthFormScreenState();
}

class _HealthFormScreenState extends State<HealthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _medicamentController = TextEditingController();
  final _veterinaireController = TextEditingController();
  final _coutController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _type = 'vaccination';
  DateTime _date = DateTime.now();
  bool _estPaye = true;

  @override
  void dispose() {
    _descriptionController.dispose();
    _medicamentController.dispose();
    _veterinaireController.dispose();
    _coutController.dispose();
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

  void _showTypeBottomSheet() {
    final types = ['vaccination', 'traitement', 'maladie', 'visite'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppTheme.spacingMedium),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLightOf(context),
                borderRadius: BorderRadius.circular(AppTheme.spacingSmall),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Type de soin',
              style: AppTheme.pageTitle.copyWith(
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            ...types.map((type) => ListTile(
              leading: Icon(
                Icons.favorite,
                color: _type == type ? AppTheme.primaryPurple : AppTheme.textSecondaryOf(context),
              ),
              title: Text(
                type[0].toUpperCase() + type.substring(1),
                style: _type == type
                    ? AppTheme.listItemTitle.copyWith(color: AppTheme.primaryPurple)
                    : AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
              ),
              trailing: _type == type
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryPurple)
                  : null,
              onTap: () {
                setState(() => _type = type);
                Navigator.pop(context);
              },
            )),
            SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final sante = Sante(
        id: const Uuid().v4(),
        animalId: widget.animalId,
        date: _date,
        type: _type,
        description: _descriptionController.text,
        medicament: _medicamentController.text.isEmpty ? null : _medicamentController.text,
        veterinaire: _veterinaireController.text.isEmpty ? null : _veterinaireController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        cout: _coutController.text.isEmpty ? null : double.parse(_coutController.text),
        estPaye: _estPaye,
      );

      DatabaseService.ajouterSante(sante);
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
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
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
          'Ajouter santé',
          style: AppTheme.pageTitle.copyWith(
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingXLarge),
          children: [
            GestureDetector(
              onTap: _showTypeBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                    const SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Text(
                        _type[0].toUpperCase() + _type.substring(1),
                        style: AppTheme.formInput,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: AppTheme.formHint,
                prefixIcon: Icon(Icons.description_outlined, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
              ),
              style: AppTheme.formInput,
              validator: (v) => v?.isEmpty ?? true ? 'La description est requise' : null,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            TextFormField(
              controller: _medicamentController,
              decoration: InputDecoration(
                hintText: 'Médicament (optionnel)',
                hintStyle: AppTheme.formHint,
                prefixIcon: Icon(Icons.medication, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
              ),
              style: AppTheme.formInput,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            TextFormField(
              controller: _veterinaireController,
              decoration: InputDecoration(
                hintText: 'Vétérinaire (optionnel)',
                hintStyle: AppTheme.formHint,
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
              ),
              style: AppTheme.formInput,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXSmall),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: SwitchListTile(
                title: Text(
                  'Payé',
                  style: AppTheme.formLabel.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Le soin est-il payé ?',
                  style: AppTheme.formHint,
                ),
                value: _estPaye,
                onChanged: (v) => setState(() => _estPaye = v),
                activeThumbColor: AppTheme.primaryPurple,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              ),
            ),
            if (_estPaye) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              TextFormField(
                controller: _coutController,
                decoration: InputDecoration(
                  hintText: 'Coût (€) - optionnel',
                  hintStyle: AppTheme.formHint,
                  prefixIcon: Icon(Icons.euro, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColorOf(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
                ),
                style: AppTheme.formInput,
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: AppTheme.spacingLarge),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                    const SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: AppTheme.bodyTextSecondary,
                          ),
                          Text(
                            DateFormat('d MMMM yyyy', 'fr_FR').format(_date),
                            style: AppTheme.formLabel,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_outlined, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Notes (optionnel)',
                hintStyle: AppTheme.formHint,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spacingXXLarge),
                  child: Icon(Icons.edit_note_outlined, color: AppTheme.textSecondary, size: AppTheme.iconSizeMedium),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColorOf(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
              ),
              style: AppTheme.formInput,
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spacingXXLarge),
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