import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class ReproductionProvider with ChangeNotifier {
  List<Reproduction> _reproductions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Reproduction> get reproductions => _reproductions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> chargerReproductions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reproductions = await DatabaseService.getReproductions();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des événements de reproduction: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ajouterReproduction(Reproduction reproduction) async {
    try {
      await DatabaseService.ajouterReproduction(reproduction);
      await chargerReproductions();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierReproduction(Reproduction reproduction) async {
    try {
      await DatabaseService.updateReproduction(reproduction);
      await chargerReproductions();
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerReproduction(String id) async {
    try {
      await DatabaseService.deleteReproduction(id);
      await chargerReproductions();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression: $e';
      notifyListeners();
      rethrow;
    }
  }

  List<Reproduction> filtrerParAnimal(String animalId) {
    return _reproductions.where((r) => r.animalId == animalId).toList()
      ..sort((a, b) => b.dateEvenement.compareTo(a.dateEvenement));
  }
}
