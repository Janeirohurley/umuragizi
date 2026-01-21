import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';

class HorizontalDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final int daysToShow;
  final List<DateTime>? datesWithTasks;

  const HorizontalDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysToShow = 7,
    this.datesWithTasks,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = selectedDate.subtract(Duration(days: (daysToShow ~/ 2)));

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daysToShow,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, today);
          final hasTask = datesWithTasks?.any((d) => _isSameDay(d, date)) ?? false;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 55,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : AppTheme.spacingSmall,
                right: index == daysToShow - 1 ? 0 : AppTheme.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPurple : AppTheme.cardBackgroundOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: isSelected ? AppTheme.cardShadow : AppTheme.softShadow,
                border: hasTask && !isSelected
                    ? Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3), width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'fr_FR').format(date).substring(0, 3),
                    style: AppTheme.bodyTextLight.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : AppTheme.textLightOf(context),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Text(
                    date.day.toString(),
                    style: AppTheme.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isToday)
                        Container(
                          width: AppTheme.spacingSmall,
                          height: AppTheme.spacingSmall,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppTheme.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (hasTask && !isToday)
                        Container(
                          width: AppTheme.spacingSmall,
                          height: AppTheme.spacingSmall,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppTheme.warningOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class MonthYearHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTap;

  const MonthYearHeader({
    super.key,
    required this.date,
    this.onPrevious,
    this.onNext,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onPrevious != null)
          IconButton(
            icon: Icon(Icons.chevron_left, color: AppTheme.textSecondaryOf(context)),
            onPressed: onPrevious,
          )
        else
          SizedBox(width: AppTheme.spacingXXLarge),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: AppTheme.iconSizeSmall,
                color: AppTheme.primaryPurple,
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                DateFormat('d MMM, yyyy', 'fr_FR').format(date),
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textSecondaryOf(context),
              ),
            ],
          ),
        ),
        if (onNext != null)
          IconButton(
            icon: Icon(Icons.chevron_right, color: AppTheme.textSecondaryOf(context)),
            onPressed: onNext,
          )
        else
          SizedBox(width: AppTheme.spacingXXLarge),
      ],
    );
  }
}