import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class AnimalProvider extends ChangeNotifier {
  List<Animal> _animaux = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Animal> get animaux => _animaux;
  int get nombreAnimaux => _animaux.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void chargerAnimaux() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _animaux = DatabaseService.getTousLesAnimaux();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des animaux: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ajouterAnimal(Animal animal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.ajouterAnimal(animal);
      chargerAnimaux();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> modifierAnimal(Animal animal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.modifierAnimal(animal);
      chargerAnimaux();
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> supprimerAnimal(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.supprimerAnimal(id);
      chargerAnimaux();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Animal? getAnimal(String id) {
    return DatabaseService.getAnimal(id);
  }

  List<Animal> rechercherAnimaux(String query) {
    if (query.isEmpty) return _animaux;
    final lowerQuery = query.toLowerCase();
    return _animaux.where((animal) {
      return animal.nom.toLowerCase().contains(lowerQuery) ||
          animal.espece.toLowerCase().contains(lowerQuery) ||
          animal.race.toLowerCase().contains(lowerQuery) ||
          animal.identifiant.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Animal> filtrerParEspece(String espece) {
    if (espece.isEmpty) return _animaux;
    return _animaux.where((animal) => animal.espece == espece).toList();
  }

  List<String> get especes {
    return _animaux.map((a) => a.espece).toSet().toList();
  }
}
