import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/rappel_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/widgets.dart';

class ReproductionFormScreen extends StatefulWidget {
  final Animal animal;
  final Reproduction? reproduction;

  const ReproductionFormScreen({
    super.key,
    required this.animal,
    this.reproduction,
  });

  @override
  State<ReproductionFormScreen> createState() => _ReproductionFormScreenState();
}

class _ReproductionFormScreenState extends State<ReproductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late DateTime _dateEvenement;
  String _typeEvenement = 'Saillie';
  String? _partenaireId;
  bool _succes = true;

  final List<String> _typesEvenement = [
    'Saillie',
    'Insémination',
    'Diagnostic gestation',
    'Mise bas',
    'Avortement'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.reproduction != null) {
      _dateEvenement = widget.reproduction!.dateEvenement;
      _typeEvenement = widget.reproduction!.typeEvenement;
      _notesController.text = widget.reproduction!.notes ?? '';
      _partenaireId = widget.reproduction!.partenaireId;
      _succes = widget.reproduction!.succes;
    } else {
      _dateEvenement = DateTime.now();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int _getJoursGestation(String espece) {
    switch (espece.toLowerCase()) {
      case 'bovin': return 283;
      case 'équin': return 340;
      case 'ovin': return 152;
      case 'caprin': return 150;
      case 'porcin': return 114;
      case 'lapin': return 31;
      case 'volaille': return 21;
      default: return 0;
    }
  }

  Future<void> _selectDate() async {
    final date = await CustomDatePicker.show(
      context,
      initialDate: _dateEvenement,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      title: 'Date de l\'événement',
    );
    if (date != null) {
      setState(() => _dateEvenement = date);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      DateTime? datePrevueMiseBas = widget.reproduction?.datePrevueMiseBas;
      
      // Calcul et création du rappel si saillie/insémination
      if (widget.reproduction == null && 
         (_typeEvenement == 'Saillie' || _typeEvenement == 'Insémination')) {
        final jours = _getJoursGestation(widget.animal.espece);
        if (jours > 0) {
          datePrevueMiseBas = _dateEvenement.add(Duration(days: jours));
          
          final dateRappel = datePrevueMiseBas.subtract(const Duration(days: 7));
          final rappel = Rappel(
            id: const Uuid().v4(),
            animalId: widget.animal.id,
            titre: 'Mise bas imminente (${widget.animal.nom})',
            description: 'Préparez-vous pour la naissance prévue vers le ${DateFormat('dd/MM/yyyy').format(datePrevueMiseBas)}',
            dateRappel: dateRappel,
            type: 'Soin spécifique',
          );
          context.read<RappelProvider>().ajouterRappel(rappel);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rappel de naissance généré pour le ${DateFormat('dd/MM/yyyy').format(dateRappel)}'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      }

      final reproduction = Reproduction(
        id: widget.reproduction?.id ?? const Uuid().v4(),
        animalId: widget.animal.id,
        dateEvenement: _dateEvenement,
        typeEvenement: _typeEvenement,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        datePrevueMiseBas: datePrevueMiseBas,
        partenaireId: _partenaireId,
        succes: _succes,
      );

      if (widget.reproduction == null) {
        context.read<ReproductionProvider>().ajouterReproduction(reproduction);
      } else {
        context.read<ReproductionProvider>().modifierReproduction(reproduction);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: AppBar(
        title: Text(
          widget.reproduction == null ? 'Nouvel événement' : 'Modifier',
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
            const Text('Type d\'événement', style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingMedium),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _typeEvenement,
                  isExpanded: true,
                  items: _typesEvenement.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type, style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context))),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _typeEvenement = val!),
                ),
              ),
            ),
            
            SizedBox(height: AppTheme.spacingLarge),
            const Text('Date', style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingMedium),
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
                        DateFormat('d MMMM yyyy', 'fr_FR').format(_dateEvenement),
                        style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_typeEvenement == 'Diagnostic gestation') ...[
              SizedBox(height: AppTheme.spacingLarge),
              SwitchListTile(
                title: Text('Gestation confirmée ?', style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context))),
                value: _succes,
                activeColor: AppTheme.primaryPurple,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _succes = val),
              ),
            ],

            SizedBox(height: AppTheme.spacingLarge),
            const Text('Notes (Optionnel)', style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingMedium),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context)),
              decoration: InputDecoration(
                hintText: 'Détails, numéro de lot, observation...',
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
              text: widget.reproduction == null ? 'Ajouter' : 'Enregistrer',
              icon: Icons.check,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
