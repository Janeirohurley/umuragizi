import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _apiBase = 'https://api.yadio.io/exrates/USD';
  static const String _cacheKey = 'cached_exchange_rates';
  static const String _cacheTimeKey = 'cached_rates_timestamp';

  // Taux par défaut (Valeurs approximatives si l'API échoue au premier lancement)
  static Map<String, double> _rates = {
    'USD': 1.0,
    'BIF': 2850.0,
    'KES': 135.0,
    'EUR': 0.92,
  };

  static Map<String, double> get rates => _rates;

  static Future<void> init() async {
    await _loadFromCache();
    await fetchRates(); // Tenter de mettre à jour au démarrage
  }

  static Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      final Map<String, dynamic> decoded = json.decode(cachedData);
      _rates = decoded.map((key, value) => MapEntry(key, value.toDouble()));
    }
  }

  static Future<void> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(_apiBase));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Yadio renvoie un objet avec les devises en clés directes
        _rates['USD'] = 1.0;
        if (data.containsKey('BIF')) _rates['BIF'] = data['BIF'].toDouble();
        if (data.containsKey('KES')) _rates['KES'] = data['KES'].toDouble();
        if (data.containsKey('EUR')) _rates['EUR'] = data['EUR'].toDouble();

        // Sauvegarder en cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, json.encode(_rates));
        await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Erreur lors de la récupération des taux : $e');
    }
  }

  /// Convertit un montant depuis la devise de base (USD) vers la devise cible
  static double convert(double amount, String toCurrency) {
    final rate = _rates[toCurrency] ?? 1.0;
    return amount * rate;
  }
}
