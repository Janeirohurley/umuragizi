import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/rappel_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ReminderFormScreen extends StatefulWidget {
  final String animalId;
  final Rappel? rappel;

  const ReminderFormScreen({super.key, required this.animalId, this.rappel});

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _type;
  late DateTime _dateRappel;
  late bool _recurrent;
  late String _uniteIntervalle;
  late int _intervalleJours;
  late int _intervalleHeures;
  late bool _avecDateFin;
  DateTime? _dateFin;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.rappel != null) {
      _titreController.text = widget.rappel!.titre;
      _descriptionController.text = widget.rappel!.description;
      _type = widget.rappel!.type;
      _dateRappel = widget.rappel!.dateRappel;
      _recurrent = widget.rappel!.recurrent;
      _intervalleJours = widget.rappel!.intervalleJours ?? 30;
      _intervalleHeures = widget.rappel!.intervalleHeures ?? 2;
      _uniteIntervalle =
          widget.rappel!.intervalleHeures != null ? 'heures' : 'jours';
      _dateFin = widget.rappel!.dateFin;
      _avecDateFin = _dateFin != null;
    } else {
      _type = 'Vaccination';
      _dateRappel = DateTime.now().add(const Duration(days: 7));
      _recurrent = false;
      _uniteIntervalle = 'jours';
      _intervalleJours = 30;
      _intervalleHeures = 2;
      _avecDateFin = false;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final l10n = AppLocalizations.of(context)!;
    final date = await CustomDatePicker.show(
      context,
      initialDate: _dateRappel,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      title: l10n.date,
    );
    if (date != null) setState(() => _dateRappel = date);
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final rappel = Rappel(
        id: widget.rappel?.id ?? const Uuid().v4(),
        animalId: widget.animalId,
        titre: _titreController.text,
        description: _descriptionController.text,
        dateRappel: _dateRappel,
        type: _type,
        recurrent: _recurrent,
        intervalleJours:
            _recurrent && _uniteIntervalle == 'jours' ? _intervalleJours : null,
        intervalleHeures: _recurrent && _uniteIntervalle == 'heures'
            ? _intervalleHeures
            : null,
        dateFin: _recurrent && _avecDateFin ? _dateFin : null,
      );
      if (widget.rappel == null) {
        context.read<RappelProvider>().ajouterRappel(rappel);
      } else {
        context.read<RappelProvider>().modifierRappel(rappel);
      }
      await NotificationService.scheduleReminderNotification(rappel);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            child: Icon(Icons.arrow_back,
                color: AppTheme.textPrimaryOf(context),
                size: AppTheme.iconSizeMedium),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.rappel == null ? l10n.newTask : l10n.editTask,
          style: AppTheme.pageTitle
              .copyWith(color: AppTheme.textPrimaryOf(context)),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingXLarge),
          children: [
            _buildSectionTitle(l10n.taskType),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildTypeSelector(),
            const SizedBox(height: AppTheme.spacingXXLarge),
            _buildSectionTitle(l10n.details),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildTextField(
              controller: _titreController,
              label: l10n.title,
              icon: Icons.title,
              validator: (v) => v?.isEmpty ?? true ? l10n.titleRequired : null,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildTextField(
              controller: _descriptionController,
              label: l10n.description,
              icon: Icons.description_outlined,
              maxLines: 3,
              validator: (v) =>
                  v?.isEmpty ?? true ? l10n.descriptionRequired : null,
            ),
            const SizedBox(height: AppTheme.spacingXXLarge),
            _buildSectionTitle(l10n.planning),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildDateSelector(),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildRecurrenceToggle(l10n),
            if (_recurrent) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              _buildUniteSelector(l10n),
              const SizedBox(height: AppTheme.spacingLarge),
              _buildFrequencySelector(l10n),
              const SizedBox(height: AppTheme.spacingLarge),
              _buildDateFinToggle(l10n),
              if (_avecDateFin) ...[
                const SizedBox(height: AppTheme.spacingLarge),
                _buildDateFinSelector(l10n),
              ],
            ],
            const SizedBox(height: AppTheme.spacingXXLarge),
            PrimaryButton(
              text: widget.rappel == null ? l10n.createTask : l10n.save,
              icon: widget.rappel == null ? Icons.add : Icons.check,
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: AppTheme.sectionTitle
            .copyWith(color: AppTheme.textPrimaryOf(context)));
  }

  String _getLabelForType(String type, AppLocalizations l10n) {
    switch (type) {
      case 'Vaccination':
        return l10n.typeVaccination;
      case 'Vermifuge':
        return l10n.typeVermifuge;
      case 'Visite vétérinaire':
        return l10n.typeVetVisit;
      case 'Soin spécifique':
        return l10n.typeSpecificCare;
      default:
        return l10n.typeOther;
    }
  }

  Widget _buildTypeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: AppTheme.spacingSmall,
      runSpacing: AppTheme.spacingSmall,
      children: AppConstants.typesRappel.map((type) {
        final isSelected = _type == type;
        return GestureDetector(
          onTap: () => setState(() => _type = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getColorForType(type)
                  : AppTheme.cardBackgroundOf(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.softShadow,
              border: Border.all(
                  color:
                      isSelected ? _getColorForType(type) : Colors.transparent,
                  width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getIconForType(type),
                    size: AppTheme.iconSizeSmall,
                    color: isSelected ? Colors.white : _getColorForType(type)),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(_getLabelForType(type, l10n),
                    style: AppTheme.cardSubtitle.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textSecondaryOf(context),
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
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
                padding: const EdgeInsets.only(bottom: AppTheme.spacingXXLarge),
                child: Icon(icon,
                    color: AppTheme.textSecondaryOf(context),
                    size: AppTheme.iconSizeMedium),
              )
            : Icon(icon,
                color: AppTheme.textSecondaryOf(context),
                size: AppTheme.iconSizeSmall),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 1),
        ),
        filled: true,
        fillColor: AppTheme.surfaceColorOf(context),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLarge,
            vertical: AppTheme.spacingMedium),
      ),
    );
  }

  Widget _buildDateSelector() {
    final settings = context.watch<SettingsProvider>();
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
            color: AppTheme.surfaceColorOf(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
                child: Text(
                    '${_dateRappel.day.toString().padLeft(2, '0')} ${settings.monthName(_dateRappel.month)} ${_dateRappel.year}',
                    style: AppTheme.formLabel)),
            Icon(Icons.edit_calendar_outlined,
                color: AppTheme.textLightOf(context),
                size: AppTheme.iconSizeMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXSmall),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColorOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
      child: SwitchListTile(
        title: Text(l10n.recurringTask,
            style: AppTheme.cardSubtitle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryOf(context))),
        subtitle: Text(l10n.repeatsAutomatically,
            style: AppTheme.bodyText
                .copyWith(color: AppTheme.textSecondaryOf(context))),
        value: _recurrent,
        onChanged: (v) => setState(() => _recurrent = v),
        activeTrackColor: AppTheme.lightPurple,
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppTheme.primaryPurple
                : AppTheme.textLightOf(context)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      ),
    );
  }

  Widget _buildUniteSelector(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColorOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.repeatUnit,
              style: AppTheme.cardSubtitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryOf(context))),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                  child: _buildUniteButton(
                      'heures', l10n.hours, Icons.access_time)),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                  child: _buildUniteButton(
                      'jours', l10n.days, Icons.calendar_today)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUniteButton(String value, String label, IconData icon) {
    final isSelected = _uniteIntervalle == value;
    return GestureDetector(
      onTap: () => setState(() => _uniteIntervalle = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPurple
              : AppTheme.cardBackgroundOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: AppTheme.iconSizeSmall,
                color: isSelected
                    ? Colors.white
                    : AppTheme.textSecondaryOf(context)),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(label,
                style: AppTheme.cardSubtitle.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textSecondaryOf(context),
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(AppLocalizations l10n) {
    final settings = context.watch<SettingsProvider>();
    if (_uniteIntervalle == 'heures') {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
            color: AppTheme.surfaceColorOf(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.access_time,
                  color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(l10n.everyHours,
                  style: AppTheme.cardSubtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryOf(context))),
            ]),
            const SizedBox(height: AppTheme.spacingMedium),
            Wrap(
              spacing: AppTheme.spacingSmall,
              runSpacing: AppTheme.spacingSmall,
              children: [1, 2, 3, 4, 6, 8, 12].map((h) {
                final isSelected = _intervalleHeures == h;
                return GestureDetector(
                  onTap: () => setState(() => _intervalleHeures = h),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMedium,
                        vertical: AppTheme.spacingSmall),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryPurple
                          : AppTheme.cardBackgroundOf(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(settings.timeLabel(h),
                        style: AppTheme.bodyTextSecondary.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondaryOf(context),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    final frequencies = [
      {'value': 7, 'label': l10n.everyWeek},
      {'value': 30, 'label': l10n.everyMonth},
      {'value': 90, 'label': l10n.every3Months},
      {'value': 180, 'label': l10n.every6Months},
      {'value': 365, 'label': l10n.everyYear},
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColorOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.repeat,
                color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(l10n.frequency,
                style: AppTheme.cardSubtitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryOf(context))),
          ]),
          const SizedBox(height: AppTheme.spacingMedium),
          Wrap(
            spacing: AppTheme.spacingSmall,
            runSpacing: AppTheme.spacingSmall,
            children: frequencies.map((freq) {
              final isSelected = _intervalleJours == freq['value'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _intervalleJours = freq['value'] as int),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryPurple
                        : AppTheme.cardBackgroundOf(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(freq['label'] as String,
                      style: AppTheme.bodyTextSecondary.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondaryOf(context),
                        fontWeight: FontWeight.w500,
                      )),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFinToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXSmall),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColorOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
      child: SwitchListTile(
        title: Text(l10n.setDuration,
            style: AppTheme.cardSubtitle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryOf(context))),
        subtitle: Text(l10n.taskStopsAuto,
            style: AppTheme.bodyText
                .copyWith(color: AppTheme.textSecondaryOf(context))),
        value: _avecDateFin,
        onChanged: (v) {
          setState(() {
            _avecDateFin = v;
            if (v && _dateFin == null)
              _dateFin = _dateRappel.add(const Duration(days: 21));
          });
        },
        activeTrackColor: AppTheme.lightPurple,
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppTheme.primaryPurple
                : AppTheme.textLightOf(context)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      ),
    );
  }

  Widget _buildDateFinSelector(AppLocalizations l10n) {
    final settings = context.watch<SettingsProvider>();
    return GestureDetector(
      onTap: () async {
        final date = await CustomDatePicker.show(
          context,
          initialDate: _dateFin ?? _dateRappel.add(const Duration(days: 21)),
          firstDate: _dateRappel.add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          title: l10n.endDate,
        );
        if (date != null) setState(() => _dateFin = date);
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
            color: AppTheme.surfaceColorOf(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
        child: Row(
          children: [
            Icon(Icons.event_busy,
                color: AppTheme.primaryPurple, size: AppTheme.iconSizeMedium),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Text(
                _dateFin != null
                    ? '${_dateFin!.day.toString().padLeft(2, '0')} ${settings.monthName(_dateFin!.month)} ${_dateFin!.year}'
                    : l10n.selectDate,
                style:
                    _dateFin != null ? AppTheme.formLabel : AppTheme.formHint,
              ),
            ),
            Icon(Icons.calendar_today_outlined,
                color: AppTheme.textLightOf(context),
                size: AppTheme.iconSizeMedium),
          ],
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
