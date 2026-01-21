import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';

class CustomDatePicker {
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
  }) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DatePickerBottomSheet(
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(1990),
        lastDate: lastDate ?? DateTime.now(),
        title: title ?? 'Sélectionner une date',
      ),
    );
  }
}

class _DatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const _DatePickerBottomSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  List<DateTime?> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    final days = <DateTime?>[];
    
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }
    
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_displayedMonth.year, _displayedMonth.month, i));
    }
    
    return days;
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool _isToday(DateTime? date) {
    return _isSameDay(date, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundOf(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            width: AppTheme.spacingXXLarge,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textLightOf(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
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
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColorOf(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  icon: Icon(Icons.close, size: AppTheme.iconSizeMedium, color: AppTheme.textSecondaryOf(context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColorOf(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  icon: Icon(Icons.chevron_left, color: AppTheme.textPrimaryOf(context)),
                ),
                Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(_displayedMonth),
                  style: AppTheme.cardTitle.copyWith(
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColorOf(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  icon: Icon(Icons.chevron_right, color: AppTheme.textPrimaryOf(context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                  .map((day) => SizedBox(
                        width: AppTheme.spacingXXLarge,
                        child: Center(
                          child: Text(
                            day,
                            style: AppTheme.bodyTextSecondary.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondaryOf(context),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: AppTheme.spacingSmall,
                crossAxisSpacing: AppTheme.spacingSmall,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                if (date == null) {
                  return const SizedBox();
                }

                final isSelected = _isSameDay(date, _selectedDate);
                final isToday = _isToday(date);
                final isDisabled = date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () {
                          setState(() => _selectedDate = date);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryPurple
                          : isToday
                              ? AppTheme.lightPurple
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                          color: isDisabled
                              ? AppTheme.textLightOf(context)
                              : isSelected
                                  ? Colors.white
                                  : isToday
                                      ? AppTheme.primaryPurple
                                      : AppTheme.textPrimaryOf(context),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXLarge),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        side: BorderSide(color: AppTheme.surfaceColorOf(context)),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: AppTheme.buttonTextSecondary.copyWith(
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: Text(
                      'Confirmer',
                      style: AppTheme.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}