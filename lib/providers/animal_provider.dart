import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class AnimalProvider extends ChangeNotifier {
  List<Animal> _animaux = [];

  List<Animal> get animaux => _animaux;

  int get nombreAnimaux => _animaux.length;

  void chargerAnimaux() {
    _animaux = DatabaseService.getTousLesAnimaux();
    notifyListeners();
  }

  Future<void> ajouterAnimal(Animal animal) async {
    await DatabaseService.ajouterAnimal(animal);
    chargerAnimaux();
  }

  Future<void> modifierAnimal(Animal animal) async {
    await DatabaseService.modifierAnimal(animal);
    chargerAnimaux();
  }

  Future<void> supprimerAnimal(String id) async {
    await DatabaseService.supprimerAnimal(id);
    chargerAnimaux();
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
