import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String keyLocale = 'user_locale';
  static const String keyCurrency = 'user_currency';

  Locale _locale = const Locale('fr');
  String _currency = 'BIF'; // Par défaut Franc Burundais

  SettingsProvider() {
    _loadSettings();
  }

  Locale get locale => _locale;
  String get currency => _currency;

  /// Retourne un code de locale compatible avec la bibliothèque intl
  String get intlLocale {
    final code = _locale.languageCode;
    if (code == 'rn') return 'fr'; // Fallback Kirundi -> Français pour intl
    return code;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(keyLocale) ?? 'fr';
    final currencyCode = prefs.getString(keyCurrency) ?? 'BIF';

    _locale = Locale(localeCode);
    _currency = currencyCode;
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLocale, newLocale.languageCode);
  }

  Future<void> setCurrency(String newCurrency) async {
    _currency = newCurrency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCurrency, newCurrency);
  }

  String get currencySymbol {
    switch (_currency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'KES': return 'KSh';
      case 'BIF': return 'FBu';
      default: return _currency;
    }
  }
}
