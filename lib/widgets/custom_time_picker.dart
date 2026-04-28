import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_theme.dart';



class CustomTimePicker {
  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
    String? title,
  }) async {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimePickerBottomSheet(
        initialTime: initialTime,
        title: title ?? AppLocalizations.of(context)!.selectTime,
      ),
    );
  }
}

class _TimePickerBottomSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final String title;

  const _TimePickerBottomSheet({
    required this.initialTime,
    required this.title,
  });

  @override
  State<_TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<_TimePickerBottomSheet> {
  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundOf(context),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          // Barre de drag (Handle)
          Container(
            width: AppTheme.spacingXXLarge,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textLightOf(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTheme.bottomSheetTitle.copyWith(
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close,
                      color: AppTheme.textSecondaryOf(context)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXLarge),

          // Time Picker Wheels
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Highlight bar au centre
                Container(
                  height: 45,
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXLarge),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColorOf(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Heures
                    _buildTimeWheel(
                      controller: _hourController,
                      count: 24,
                      onChanged: (val) => setState(() => _selectedHour = val),
                    ),
                    Text(":", style: AppTheme.cardTitle.copyWith(fontSize: 24)),
                    // Minutes
                    _buildTimeWheel(
                      controller: _minuteController,
                      count: 60,
                      onChanged: (val) => setState(() => _selectedMinute = val),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXLarge),

          // Actions
       Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXLarge),
            child: Row(
              children: [
                // Bouton Annuler
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMedium),
                      side: BorderSide(color: AppTheme.surfaceColorOf(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Style "md" plus sobre
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: AppTheme.buttonTextSecondary.copyWith(
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppTheme.spacingMedium),

                // Bouton Confirmer
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0, // Design plat pour le look Corporate
                      padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Style "md" consistant
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: AppTheme.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimeWheel({
    required FixedExtentScrollController controller,
    required int count,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 70,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 45,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, index) {
            final isSelected =
                (controller.initialItem == index); // Simplifié pour l'exemple
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: AppTheme.cardTitle.copyWith(
                  color: AppTheme.textPrimaryOf(context),
                  fontSize: 22,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
