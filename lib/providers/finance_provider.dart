import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class FinanceProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalRevenus => _transactions
      .where((t) => t.type == 'Revenu')
      .fold(0, (sum, t) => sum + t.montant);

  double get totalDepenses => _transactions
      .where((t) => t.type == 'Dépense')
      .fold(0, (sum, t) => sum + t.montant);

  double get solde => totalRevenus - totalDepenses;

  Future<void> chargerTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await DatabaseService.getTransactions();
      // On trie du plus récent au plus ancien
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ajouterTransaction(Transaction transaction) async {
    try {
      await DatabaseService.ajouterTransaction(transaction);
      await chargerTransactions();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierTransaction(Transaction transaction) async {
    try {
      await DatabaseService.modifierTransaction(transaction);
      await chargerTransactions();
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerTransaction(String id) async {
    try {
      await DatabaseService.supprimerTransaction(id);
      await chargerTransactions();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression: $e';
      notifyListeners();
      rethrow;
    }
  }

  List<Transaction> filtrerParAnimal(String animalId) {
    return _transactions.where((t) => t.animalId == animalId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
