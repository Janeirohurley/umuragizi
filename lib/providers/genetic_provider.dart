import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../services/genetic_service.dart';

class GeneticProvider extends ChangeNotifier {
  List<GeneticInfo> _geneticInfos = [];
  bool _isLoading = false;
  bool _isBulkUpdating = false;
  String? _errorMessage;
  final Set<String> _updatingAnimalIds = <String>{};

  List<GeneticInfo> get geneticInfos => _geneticInfos;
  bool get isLoading => _isLoading;
  bool get isBulkUpdating => _isBulkUpdating;
  String? get errorMessage => _errorMessage;

  Future<void> chargerGeneticInfos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _geneticInfos = DatabaseService.getAllGeneticInfos()
        ..sort((a, b) => b.lastCalculatedAt.compareTo(a.lastCalculatedAt));
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des donnees genetiques: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  GeneticInfo? getGeneticInfo(String animalId) {
    for (final info in _geneticInfos) {
      if (info.animalId == animalId) {
        return info;
      }
    }
    return DatabaseService.getGeneticInfo(animalId);
  }

  bool isUpdatingAnimal(String animalId) => _updatingAnimalIds.contains(animalId);

  Future<GeneticInfo?> updateForAnimal(Animal animal) async {
    _updatingAnimalIds.add(animal.id);
    _errorMessage = null;
    notifyListeners();

    try {
      final herd = DatabaseService.getTousLesAnimaux();
      final info = await GeneticService.updateGeneticInfo(
        animal,
        population: herd,
      );
      _upsertInfo(info);
      return info;
    } catch (e) {
      _errorMessage = 'Erreur lors du calcul genetique: $e';
      notifyListeners();
      return null;
    } finally {
      _updatingAnimalIds.remove(animal.id);
      notifyListeners();
    }
  }

  Future<void> recalculateAll() async {
    _isBulkUpdating = true;
    _errorMessage = null;
    final herd = DatabaseService.getTousLesAnimaux();
    _updatingAnimalIds.addAll(herd.map((animal) => animal.id));
    notifyListeners();

    try {
      final infos = <GeneticInfo>[];
      for (final animal in herd) {
        final info = await GeneticService.updateGeneticInfo(
          animal,
          population: herd,
        );
        infos.add(info);
      }
      _geneticInfos = infos
        ..sort((a, b) => b.lastCalculatedAt.compareTo(a.lastCalculatedAt));
    } catch (e) {
      _errorMessage = 'Erreur lors du recalcul genetique: $e';
    } finally {
      _updatingAnimalIds.clear();
      _isBulkUpdating = false;
      notifyListeners();
    }
  }

  void _upsertInfo(GeneticInfo info) {
    _geneticInfos = [
      for (final current in _geneticInfos)
        if (current.animalId != info.animalId) current,
      info,
    ]..sort((a, b) => b.lastCalculatedAt.compareTo(a.lastCalculatedAt));
  }
}
