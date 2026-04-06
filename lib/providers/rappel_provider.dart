import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class RappelProvider extends ChangeNotifier {
  List<Rappel> _rappels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Rappel> get rappels => _rappels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Rappel> get rappelsDuJour => DatabaseService.getRappelsDuJour();
  List<Rappel> get rappelsEnRetard => DatabaseService.getRappelsEnRetard();
  List<Rappel> get rappelsAVenir => DatabaseService.getRappelsAVenir();

  int get nombreRappelsDuJour => rappelsDuJour.length;
  int get nombreRappelsEnRetard => rappelsEnRetard.length;

  void chargerRappels() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _rappels = DatabaseService.getTousLesRappels();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des rappels: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Rappel> getRappelsParAnimal(String animalId) {
    return DatabaseService.getRappelsParAnimal(animalId);
  }

  Future<void> ajouterRappel(Rappel rappel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await DatabaseService.ajouterRappel(rappel);
      chargerRappels();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout du rappel: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> modifierRappel(Rappel rappel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await DatabaseService.modifierRappel(rappel);
      chargerRappels();
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification du rappel: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> supprimerRappel(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await DatabaseService.supprimerRappel(id);
      chargerRappels();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du rappel: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> marquerComplete(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await DatabaseService.marquerRappelComplete(id);
      chargerRappels();
    } catch (e) {
      _errorMessage = 'Erreur lors de la complétion du rappel: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Rappel> getRappelsPourDate(DateTime date) {
    return _rappels.where((r) {
      return r.dateRappel.year == date.year &&
          r.dateRappel.month == date.month &&
          r.dateRappel.day == date.day;
    }).toList();
  }
}
