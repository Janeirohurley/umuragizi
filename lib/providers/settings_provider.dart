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

  /// Noms de mois traduits (index 0 = janvier)
  List<String> get monthNames {
    switch (_locale.languageCode) {
      case 'en':
        return ['January','February','March','April','May','June',
                'July','August','September','October','November','December'];
      case 'sw':
        return ['Januari','Februari','Machi','Aprili','Mei','Juni',
                'Julai','Agosti','Septemba','Oktoba','Novemba','Desemba'];
      case 'rn':
        return ['Nzero','Ruhuhuma','Ntwarante','Ndamukiza','Rusama','Ruheshi',
                'Mukakaro','Myandagaro','Nyakanga','Gitugutu','Munyonyo','Kigarama'];
      default: // fr
        return ['Janvier','Février','Mars','Avril','Mai','Juin',
                'Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    }
  }

  String monthName(int month) => monthNames[month - 1];

  /// Jours abrégés (Lundi=0 ... Dimanche=6)
  List<String> get weekdaysShort {
    switch (_locale.languageCode) {
      case 'en':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'sw':
        return ['Jum', 'Jum', 'Jum', 'Alh', 'Iju', 'Jum', 'Jum'];
      case 'rn':
        return ['Kuwamb', 'Kuwakabiri', 'Kuwagata', 'Kuwaka', 'Kuwagata', 'Kuwagatand', 'Kuwamu'];
      default: // fr
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    }
  }

  /// weekday: 1=Lundi ... 7=Dimanche (comme DateTime.weekday)
  String weekdayShort(int weekday) => weekdaysShort[weekday - 1];

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
