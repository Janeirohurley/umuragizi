import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import '../../models/models.dart';
import '../../providers/animal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../../l10n/app_localizations.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;

  const AnimalFormScreen({super.key, this.animal});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _raceController = TextEditingController();
  final _notesController = TextEditingController();
  final _prixAchatController = TextEditingController();

  String _espece = 'Bovin';
  String _sexe = 'Mâle';
  String _statut = 'Actif';
  DateTime _dateNaissance = DateTime.now();
  String? _photoPath;
  String? _photoBase64;
  String? _mereId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.animal != null) {
      _nomController.text = widget.animal!.nom;
      _espece = widget.animal!.espece;
      _raceController.text = widget.animal!.race;
      _notesController.text = widget.animal!.notes ?? '';
      _prixAchatController.text = widget.animal!.prixAchat?.toString() ?? '';
      _sexe = widget.animal!.sexe;
      _dateNaissance = widget.animal!.dateNaissance;
      _statut = widget.animal!.statut;
      _photoPath = widget.animal!.photoPath;
      _photoBase64 = widget.animal!.photoBase64;
      _mereId = widget.animal!.mereId;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _raceController.dispose();
    _notesController.dispose();
    _prixAchatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _photoPath = image.path;
        _photoBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _selectDate() async {
    final l10n = AppLocalizations.of(context)!;
    final date = await CustomDatePicker.show(
      context,
      initialDate: _dateNaissance,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      title: l10n.birthDate,
    );
    if (date != null) setState(() => _dateNaissance = date);
  }

  static int _ageMinMere(String espece) {
    switch (espece.toLowerCase()) {
      case 'bovin': return 24;
      case 'équin': return 36;
      case 'caprin': return 12;
      case 'ovin': return 12;
      case 'porcin': return 8;
      case 'volaille': return 6;
      case 'lapin': return 6;
      default: return 12;
    }
  }

  void _showMereBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    final ageMin = _ageMinMere(_espece);
    final animaux = context.read<AnimalProvider>().animaux.where((a) =>
        a.sexe == 'Femelle' &&
        a.id != widget.animal?.id &&
        a.espece.toLowerCase() == _espece.toLowerCase() &&
        a.ageEnMois >= ageMin).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppTheme.spacingMedium),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLightOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(l10n.selectMother, style: AppTheme.bottomSheetTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingLarge),
            if (animaux.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXXLarge, vertical: AppTheme.spacingXXLarge),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacingLarge),
                      decoration: BoxDecoration(color: AppTheme.warningOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.warning_amber_rounded, size: AppTheme.iconSizeXLarge, color: AppTheme.warningOrange),
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    Text(l10n.noFemaleAvailable, style: AppTheme.sectionSubtitle),
                    SizedBox(height: AppTheme.spacingSmall),
                    Text(l10n.noFemaleAvailableDesc, textAlign: TextAlign.center, style: AppTheme.bodyTextLight),
                    SizedBox(height: AppTheme.spacingXLarge),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.warningOrange.withValues(alpha: 0.1),
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                        ),
                        child: Text(l10n.understood, style: AppTheme.buttonText.copyWith(color: AppTheme.warningOrange)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: animaux.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: Icon(Icons.clear, color: AppTheme.textSecondary, size: AppTheme.iconSizeMedium),
                        title: Text(l10n.noMother, style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                        trailing: _mereId == null ? Icon(Icons.check_circle, color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium) : null,
                        onTap: () { setState(() => _mereId = null); Navigator.pop(context); },
                      );
                    }
                    final animal = animaux[index - 1];
                    final isSelected = _mereId == animal.id;
                    return ListTile(
                      leading: Icon(Icons.pets, color: isSelected ? AppTheme.primaryPurple : AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                      title: Text(animal.nom, style: isSelected
                          ? AppTheme.listItemTitle.copyWith(color: AppTheme.primaryPurple, fontWeight: FontWeight.w600)
                          : AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                      subtitle: Text('${animal.espece} • ${animal.race}', style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context))),
                      trailing: isSelected ? Icon(Icons.check_circle, color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium) : null,
                      onTap: () { setState(() => _mereId = animal.id); Navigator.pop(context); },
                    );
                  },
                ),
              ),
            SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  String _getEspeceLabel(String espece, AppLocalizations l10n) {
    switch (espece.toLowerCase()) {
      case 'bovin': return l10n.especeBovinLabel;
      case 'ovin': return l10n.especeOvinLabel;
      case 'caprin': return l10n.especeCaprinLabel;
      case 'porcin': return l10n.especePorcinLabel;
      case 'volaille': return l10n.especeVolailleLabel;
      case 'équin': return l10n.especeEquinLabel;
      case 'lapin': return l10n.especeLapinLabel;
      default: return espece;
    }
  }

  String _getExemplePourEspece(String espece) {
    final l10n = AppLocalizations.of(context)!;
    switch (espece.toLowerCase()) {
      case 'bovin': return l10n.especeBovin;
      case 'ovin': return l10n.especeOvin;
      case 'caprin': return l10n.especeCaprin;
      case 'porcin': return l10n.especePorcin;
      case 'volaille': return l10n.especeVolaille;
      case 'équin': return l10n.especeEquin;
      case 'lapin': return l10n.especeLapin;
      default: return '';
    }
  }

  void _showEspeceBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppTheme.spacingMedium),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.textLightOf(context), borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(l10n.selectSpecies, style: AppTheme.bottomSheetTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppConstants.especesCommunes.length,
                itemBuilder: (context, index) {
                  final espece = AppConstants.especesCommunes[index];
                  final isSelected = _espece == espece;
                  final exemple = _getExemplePourEspece(espece);
                  return ListTile(
                    leading: Icon(Icons.pets, color: isSelected ? AppTheme.primaryPurple : AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                    title: Text(_getEspeceLabel(espece, l10n), style: isSelected
                        ? AppTheme.listItemTitle.copyWith(color: AppTheme.primaryPurple, fontWeight: FontWeight.w600)
                        : AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
                    subtitle: exemple.isNotEmpty
                        ? Text(exemple, style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context), fontSize: 12))
                        : null,
                    trailing: isSelected ? Icon(Icons.check_circle, color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium) : null,
                    onTap: () { setState(() => _espece = espece); Navigator.pop(context); },
                  );
                },
              ),
            ),
            SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final animal = Animal(
        id: widget.animal?.id ?? const Uuid().v4(),
        nom: _nomController.text,
        espece: _espece,
        race: _raceController.text,
        sexe: _sexe,
        dateNaissance: _dateNaissance,
        photoPath: _photoPath,
        photoBase64: _photoBase64,
        identifiant: widget.animal?.identifiant ?? const Uuid().v4(),
        dateAjout: widget.animal?.dateAjout ?? DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        mereId: _mereId,
        prixAchat: _prixAchatController.text.isEmpty ? null : double.parse(_prixAchatController.text),
        statut: _statut,
      );
      if (widget.animal == null) {
        context.read<AnimalProvider>().ajouterAnimal(animal);
      } else {
        context.read<AnimalProvider>().modifierAnimal(animal);
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
          widget.animal == null ? l10n.newAnimal : l10n.edit,
          style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacingXLarge),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.lightPurple,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: AppTheme.softShadow,
                  image: _photoBase64 != null
                      ? DecorationImage(image: MemoryImage(base64Decode(_photoBase64!)), fit: BoxFit.cover)
                      : _photoPath != null
                          ? DecorationImage(image: FileImage(File(_photoPath!)), fit: BoxFit.cover)
                          : null,
                ),
                child: _photoBase64 == null && _photoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: AppTheme.iconSizeXLarge, color: AppTheme.primaryPurple),
                          SizedBox(height: AppTheme.spacingXSmall),
                          Text(l10n.addPhoto, style: AppTheme.bodyText.copyWith(color: AppTheme.primaryPurple, fontWeight: FontWeight.w500)),
                        ],
                      )
                    : null,
              ),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            Text(l10n.informations, style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            _buildTextField(
              controller: _nomController,
              label: l10n.animalName,
              icon: Icons.pets,
              validator: (v) => v?.isEmpty ?? true ? l10n.animalNameRequired : null,
            ),
            SizedBox(height: AppTheme.spacingLarge),

            GestureDetector(
              onTap: _showEspeceBottomSheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium + 2),
                decoration: BoxDecoration(color: AppTheme.surfaceColorOf(context), borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(child: Text(_getEspeceLabel(_espece, l10n), style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context)))),
                    Icon(Icons.arrow_drop_down, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeLarge),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),

            _buildTextField(
              controller: _raceController,
              label: l10n.breed,
              icon: Icons.label_outline,
              validator: (v) => v?.isEmpty ?? true ? l10n.breedRequired : null,
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            Text(l10n.characteristics, style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            _buildSexeSelector(l10n),
            SizedBox(height: AppTheme.spacingLarge),

            _buildDateSelector(settings, l10n),
            SizedBox(height: AppTheme.spacingXXLarge),

            Text(l10n.genealogy, style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            GestureDetector(
              onTap: _showMereBottomSheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium + 2),
                decoration: BoxDecoration(color: AppTheme.surfaceColorOf(context), borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                child: Row(
                  children: [
                    Icon(Icons.family_restroom, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeSmall + 1),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Text(
                        _mereId == null
                            ? l10n.selectMother
                            : context.read<AnimalProvider>().getAnimal(_mereId!)?.nom ?? l10n.unknownMother,
                        style: _mereId == null
                            ? AppTheme.formHint.copyWith(color: AppTheme.textLightOf(context))
                            : AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context)),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeLarge),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            Text(l10n.status, style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            _buildStatutSelector(),
            SizedBox(height: AppTheme.spacingXXLarge),

            Text(l10n.finances, style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            _buildTextField(
              controller: _prixAchatController,
              label: l10n.purchasePrice,
              icon: Icons.monetization_on_outlined,
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            Text(l10n.notesOptional, style: AppTheme.sectionTitle.copyWith(color: AppTheme.textPrimaryOf(context))),
            SizedBox(height: AppTheme.spacingMedium),
            _buildTextField(
              controller: _notesController,
              label: l10n.additionalNotes,
              icon: Icons.edit_note_outlined,
              maxLines: 3,
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            PrimaryButton(
              text: widget.animal == null ? l10n.addAnimalBtn : l10n.save,
              icon: widget.animal == null ? Icons.add : Icons.check,
              isLoading: _isLoading,
              onPressed: _save,
            ),
            SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: AppTheme.formInput,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: AppTheme.formHint,
        prefixIcon: maxLines > 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(icon, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeMedium),
              )
            : Icon(icon, color: AppTheme.textSecondaryOf(context), size: AppTheme.iconSizeSmall + 2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 1),
        ),
        filled: true,
        fillColor: AppTheme.surfaceColorOf(context),
        contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium - 2),
      ),
    );
  }

  Widget _buildStatutSelector() {
    final l10n = AppLocalizations.of(context)!;
    final statuts = [
      ('Actif',   l10n.statutActif,   AppTheme.successGreen,  Icons.check_circle),
      ('Vendu',   l10n.statutVendu,   AppTheme.infoBlue,      Icons.sell),
      ('Mort',    l10n.statutMort,    AppTheme.errorRed,      Icons.close),
      ('Réformé', l10n.statutReforme, AppTheme.warningOrange, Icons.block),
    ];
    return Wrap(
      spacing: AppTheme.spacingSmall,
      runSpacing: AppTheme.spacingSmall,
      children: statuts.map((s) {
        final isSelected = _statut == s.$1;
        return GestureDetector(
          onTap: () => setState(() => _statut = s.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: isSelected ? s.$3 : AppTheme.surfaceColorOf(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.$4, color: isSelected ? Colors.white : s.$3, size: AppTheme.iconSizeMedium),
                SizedBox(width: AppTheme.spacingSmall),
                Text(s.$2, style: AppTheme.bodyText.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSexeSelector(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _sexe = 'Mâle'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium - 2),
              decoration: BoxDecoration(
                color: _sexe == 'Mâle' ? AppTheme.infoBlue : AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.male, size: AppTheme.iconSizeSmall + 1, color: _sexe == 'Mâle' ? Colors.white : AppTheme.infoBlue),
                  SizedBox(width: AppTheme.spacingSmall - 2),
                  Text(l10n.male, style: AppTheme.bodyText.copyWith(
                    color: _sexe == 'Mâle' ? Colors.white : AppTheme.textSecondaryOf(context),
                    fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _sexe = 'Femelle'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium - 2),
              decoration: BoxDecoration(
                color: _sexe == 'Femelle' ? const Color(0xFFEC4899) : AppTheme.surfaceColorOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.female, size: AppTheme.iconSizeSmall + 1, color: _sexe == 'Femelle' ? Colors.white : const Color(0xFFEC4899)),
                  SizedBox(width: AppTheme.spacingSmall - 2),
                  Text(l10n.female, style: AppTheme.bodyText.copyWith(
                    color: _sexe == 'Femelle' ? Colors.white : AppTheme.textSecondaryOf(context),
                    fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(SettingsProvider settings, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingMedium + 2),
        decoration: BoxDecoration(color: AppTheme.surfaceColorOf(context), borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: AppTheme.primaryPurple, size: AppTheme.iconSizeSmall + 1),
            SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Text(
                DateFormat('d MMMM yyyy', settings.intlLocale).format(_dateNaissance),
                style: AppTheme.formLabel.copyWith(color: AppTheme.textPrimaryOf(context)),
              ),
            ),
            Icon(Icons.calendar_today_outlined, color: AppTheme.textLightOf(context), size: AppTheme.iconSizeSmall + 1),
          ],
        ),
      ),
    );
  }
}
