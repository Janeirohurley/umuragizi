import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import '../../models/models.dart';
import '../../providers/animal_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';

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
      final base64String = base64Encode(bytes);
      setState(() {
        _photoPath = image.path;
        _photoBase64 = base64String;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await CustomDatePicker.show(
      context,
      initialDate: _dateNaissance,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      title: 'Date de naissance',
    );
    if (date != null) {
      setState(() => _dateNaissance = date);
    }
  }

  void _showMereBottomSheet() {
    final animaux = context
        .read<AnimalProvider>()
        .animaux
        .where((a) => a.sexe == 'Femelle' && a.id != widget.animal?.id)
        .toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Sélectionner la mère',
              style: AppTheme.bottomSheetTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            if (animaux.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXXLarge,
                  vertical: AppTheme.spacingXXLarge,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacingLarge),
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: AppTheme.iconSizeXLarge,
                        color: AppTheme.warningOrange,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    const Text(
                      'Aucune femelle disponible',
                      style: AppTheme.sectionSubtitle,
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    const Text(
                      'Ajoutez d\'abord une femelle pour pouvoir sélectionner une mère',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyTextLight,
                    ),
                    SizedBox(height: AppTheme.spacingXLarge),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.warningOrange.withValues(alpha: 0.1),
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        child: Text(
                          'Compris',
                          style: AppTheme.buttonText.copyWith(color: AppTheme.warningOrange),
                        ),
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
                        leading: Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                          size: AppTheme.iconSizeMedium,
                        ),
                        title: Text(
                          'Aucune mère',
                          style: AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                        ),
                        trailing: _mereId == null
                            ? Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryPurple,
                                size: AppTheme.iconSizeMedium,
                              )
                            : null,
                        onTap: () {
                          setState(() => _mereId = null);
                          Navigator.pop(context);
                        },
                      );
                    }
                    final animal = animaux[index - 1];
                    final isSelected = _mereId == animal.id;
                    return ListTile(
                      leading: Icon(
                        Icons.pets,
                        color: isSelected ? AppTheme.primaryPurple : AppTheme.textSecondaryOf(context),
                        size: AppTheme.iconSizeMedium,
                      ),
                      title: Text(
                        animal.nom,
                        style: isSelected
                            ? AppTheme.listItemTitle.copyWith(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600,
                              )
                            : AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                      ),
                      subtitle: Text(
                        '${animal.espece} • ${animal.race}',
                        style: AppTheme.listItemSubtitle.copyWith(color: AppTheme.textSecondaryOf(context)),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryPurple,
                              size: AppTheme.iconSizeMedium,
                            )
                          : null,
                      onTap: () {
                        setState(() => _mereId = animal.id);
                        Navigator.pop(context);
                      },
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

  void _showEspeceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Sélectionner une espèce',
              style: AppTheme.bottomSheetTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppConstants.especesCommunes.length,
                itemBuilder: (context, index) {
                  final espece = AppConstants.especesCommunes[index];
                  final isSelected = _espece == espece;
                  return ListTile(
                    leading: Icon(
                      Icons.pets,
                      color: isSelected ? AppTheme.primaryPurple : AppTheme.textSecondaryOf(context),
                      size: AppTheme.iconSizeMedium,
                    ),
                    title: Text(
                      espece,
                      style: isSelected
                          ? AppTheme.listItemTitle.copyWith(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w600,
                            )
                          : AppTheme.listItemTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryPurple,
                            size: AppTheme.iconSizeMedium,
                          )
                        : null,
                    onTap: () {
                      setState(() => _espece = espece);
                      Navigator.pop(context);
                    },
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
        prixAchat: _prixAchatController.text.isEmpty
            ? null
            : double.parse(_prixAchatController.text),
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
            child: Icon(
              Icons.arrow_back,
              color: AppTheme.textPrimaryOf(context),
              size: AppTheme.iconSizeMedium,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.animal == null ? 'Nouvel animal' : 'Modifier',
          style: AppTheme.pageTitle.copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacingXLarge),
          children: [
            // Photo selector
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
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(_photoBase64!)),
                          fit: BoxFit.cover,
                        )
                      : _photoPath != null
                      ? DecorationImage(
                          image: FileImage(File(_photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _photoBase64 == null && _photoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: AppTheme.iconSizeXLarge,
                            color: AppTheme.primaryPurple,
                          ),
                          SizedBox(height: AppTheme.spacingXSmall),
                          Text(
                            'Ajouter photo',
                            style: AppTheme.bodyText.copyWith(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            // Nom
            const Text('Informations', style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingMedium),
            _buildTextField(
              controller: _nomController,
              label: 'Nom de l\'animal',
              icon: Icons.pets,
              validator: (v) => v?.isEmpty ?? true ? 'Le nom est requis' : null,
            ),
            SizedBox(height: AppTheme.spacingLarge),

            // Espèce
            GestureDetector(
              onTap: _showEspeceBottomSheet,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLarge,
                  vertical: AppTheme.spacingMedium + 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: AppTheme.textSecondaryOf(context),
                      size: AppTheme.iconSizeMedium,
                    ),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Text(_espece, style: AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context))),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.textLightOf(context),
                      size: AppTheme.iconSizeLarge,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),

            // Race
            _buildTextField(
              controller: _raceController,
              label: 'Race',
              icon: Icons.label_outline,
              validator: (v) => v?.isEmpty ?? true ? 'La race est requise' : null,
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            // Sexe
            const Text('Caractéristiques', style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingMedium),
            _buildSexeSelector(),
            SizedBox(height: AppTheme.spacingLarge),

            // Date de naissance
            _buildDateSelector(),
            SizedBox(height: AppTheme.spacingXXLarge),

            // Généalogie
            const Text('Généalogie (optionnel)', style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingMedium),
            GestureDetector(
              onTap: _showMereBottomSheet,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLarge,
                  vertical: AppTheme.spacingMedium + 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.family_restroom,
                      color: AppTheme.textSecondaryOf(context),
                      size: AppTheme.iconSizeSmall + 1,
                    ),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Text(
                        _mereId == null
                            ? 'Sélectionner la mère'
                            : context
                                      .read<AnimalProvider>()
                                      .getAnimal(_mereId!)
                                      ?.nom ??
                                  'Mère inconnue',
                        style: _mereId == null
                            ? AppTheme.formHint.copyWith(color: AppTheme.textLightOf(context))
                            : AppTheme.formInput.copyWith(color: AppTheme.textPrimaryOf(context)),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.textLightOf(context),
                      size: AppTheme.iconSizeLarge,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            // Finances
            const Text('Finances (optionnel)', style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingMedium),
            _buildTextField(
              controller: _prixAchatController,
              label: 'Prix d\'achat (€)',
              icon: Icons.euro,
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            // Notes
            const Text('Notes (optionnel)', style: AppTheme.sectionTitle),
            SizedBox(height: AppTheme.spacingMedium),
            _buildTextField(
              controller: _notesController,
              label: 'Notes supplémentaires',
              icon: Icons.edit_note_outlined,
              maxLines: 3,
            ),
            SizedBox(height: AppTheme.spacingXXLarge),

            // Submit button
            PrimaryButton(
              text: widget.animal == null ? 'Ajouter l\'animal' : 'Enregistrer',
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
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
        filled: true,
        fillColor: AppTheme.surfaceColorOf(context),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLarge,
          vertical: AppTheme.spacingMedium - 2,
        ),
      ),
    );
  }

  Widget _buildSexeSelector() {
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
                  Icon(
                    Icons.male,
                    size: AppTheme.iconSizeSmall + 1,
                    color: _sexe == 'Mâle' ? Colors.white : AppTheme.infoBlue,
                  ),
                  SizedBox(width: AppTheme.spacingSmall - 2),
                  Text(
                    'Mâle',
                    style: AppTheme.bodyText.copyWith(
                      color: _sexe == 'Mâle' ? Colors.white : AppTheme.textSecondaryOf(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  Icon(
                    Icons.female,
                    size: AppTheme.iconSizeSmall + 1,
                    color: _sexe == 'Femelle' ? Colors.white : const Color(0xFFEC4899),
                  ),
                  SizedBox(width: AppTheme.spacingSmall - 2),
                  Text(
                    'Femelle',
                    style: AppTheme.bodyText.copyWith(
                      color: _sexe == 'Femelle' ? Colors.white : AppTheme.textSecondaryOf(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingMedium + 2),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColorOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              color: AppTheme.primaryPurple,
              size: AppTheme.iconSizeSmall + 1,
            ),
            SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Text(
                DateFormat('d MMMM yyyy', 'fr_FR').format(_dateNaissance),
                style: AppTheme.formLabel.copyWith(color: AppTheme.textPrimaryOf(context)),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.textLightOf(context),
              size: AppTheme.iconSizeSmall + 1,
            ),
          ],
        ),
      ),
    );
  }
}
