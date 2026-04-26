import '../l10n/app_localizations.dart';

String formatAge(int ageEnMois, AppLocalizations l10n) {
  if (ageEnMois < 12) {
    return l10n.ageMonths(ageEnMois);
  }
  final annees = ageEnMois ~/ 12;
  final moisRestants = ageEnMois % 12;
  if (moisRestants == 0) {
    return annees == 1 ? l10n.ageYear(annees) : l10n.ageYears(annees);
  }
  return annees == 1
      ? l10n.ageYearMonths(annees, moisRestants)
      : l10n.ageYearsMonths(annees, moisRestants);
}
