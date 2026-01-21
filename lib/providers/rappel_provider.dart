import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class RappelProvider extends ChangeNotifier {
  List<Rappel> _rappels = [];

  List<Rappel> get rappels => _rappels;

  List<Rappel> get rappelsDuJour => DatabaseService.getRappelsDuJour();
  List<Rappel> get rappelsEnRetard => DatabaseService.getRappelsEnRetard();
  List<Rappel> get rappelsAVenir => DatabaseService.getRappelsAVenir();

  int get nombreRappelsDuJour => rappelsDuJour.length;
  int get nombreRappelsEnRetard => rappelsEnRetard.length;

  void chargerRappels() {
    _rappels = DatabaseService.getTousLesRappels();
    notifyListeners();
  }

  List<Rappel> getRappelsParAnimal(String animalId) {
    return DatabaseService.getRappelsParAnimal(animalId);
  }

  Future<void> ajouterRappel(Rappel rappel) async {
    await DatabaseService.ajouterRappel(rappel);
    chargerRappels();
  }

  Future<void> modifierRappel(Rappel rappel) async {
    await DatabaseService.modifierRappel(rappel);
    chargerRappels();
  }

  Future<void> supprimerRappel(String id) async {
    await DatabaseService.supprimerRappel(id);
    chargerRappels();
  }

  Future<void> marquerComplete(String id) async {
    await DatabaseService.marquerRappelComplete(id);
    chargerRappels();
  }

  List<Rappel> getRappelsPourDate(DateTime date) {
    return _rappels.where((r) {
      return r.dateRappel.year == date.year &&
          r.dateRappel.month == date.month &&
          r.dateRappel.day == date.day;
    }).toList();
  }
}
