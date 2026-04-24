import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../services/currency_service.dart';

class CurrencyHelper {
  /// Formate un montant de base (en USD) vers la devise choisie par l'utilisateur
  static String format(double amountInBase, SettingsProvider settings) {
    if (settings.currency == 'USD') {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amountInBase);
    }

    final converted = CurrencyService.convert(amountInBase, settings.currency);
    
    // Formater selon la devise
    final formatter = NumberFormat.currency(
      symbol: settings.currencySymbol,
      decimalDigits: settings.currency == 'BIF' ? 0 : 2,
    );
    
    return formatter.format(converted);
  }

  /// Retourne uniquement la valeur convertie (sans symbole)
  static double convert(double amountInBase, String toCurrency) {
    return CurrencyService.convert(amountInBase, toCurrency);
  }
}
