import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'google_drive_service.dart';

class DatabaseService {
  static const String animalBoxName = 'animals';
  static const String alimentationBoxName = 'alimentations';
  static const String santeBoxName = 'santes';
  static const String croissanceBoxName = 'croissances';
  static const String rappelBoxName = 'rappels';
  static const String reproductionBoxName = 'reproductions';
  static const String transactionBoxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Enregistrer les adaptateurs
    Hive.registerAdapter(AnimalAdapter());
    Hive.registerAdapter(AlimentationAdapter());
    Hive.registerAdapter(SanteAdapter());
    Hive.registerAdapter(CroissanceAdapter());
    Hive.registerAdapter(RappelAdapter());
    Hive.registerAdapter(ReproductionAdapter());
    Hive.registerAdapter(TransactionAdapter());

    // Ouvrir les boxes
    await Hive.openBox<Animal>(animalBoxName);
    await Hive.openBox<Alimentation>(alimentationBoxName);
    await Hive.openBox<Sante>(santeBoxName);
    await Hive.openBox<Croissance>(croissanceBoxName);
    await Hive.openBox<Rappel>(rappelBoxName);
    await Hive.openBox<Reproduction>(reproductionBoxName);
    await Hive.openBox<Transaction>(transactionBoxName);
  }

  // Box getters
  static Box<Animal> get animalBox => Hive.box<Animal>(animalBoxName);
  static Box<Alimentation> get alimentationBox => Hive.box<Alimentation>(alimentationBoxName);
  static Box<Sante> get santeBox => Hive.box<Sante>(santeBoxName);
  static Box<Croissance> get croissanceBox => Hive.box<Croissance>(croissanceBoxName);
  static Box<Rappel> get rappelBox => Hive.box<Rappel>(rappelBoxName);
  static Box<Reproduction> get reproductionBox => Hive.box<Reproduction>(reproductionBoxName);
  static Box<Transaction> get transactionBox => Hive.box<Transaction>(transactionBoxName);

  // CRUD Animaux
  static Future<void> ajouterAnimal(Animal animal) async {
    await animalBox.put(animal.id, animal);
    GoogleDriveService.autoSync();
  }

  static Future<void> modifierAnimal(Animal animal) async {
    await animalBox.put(animal.id, animal);
    GoogleDriveService.autoSync();
  }

  static Future<void> supprimerAnimal(String id) async {
    await animalBox.delete(id);
    // Supprimer aussi toutes les données liées
    final alimentations = alimentationBox.values.where((a) => a.animalId == id).toList();
    for (var a in alimentations) {
      await a.delete();
    }
    final santes = santeBox.values.where((s) => s.animalId == id).toList();
    for (var s in santes) {
      await s.delete();
    }
    final croissances = croissanceBox.values.where((c) => c.animalId == id).toList();
    for (var c in croissances) {
      await c.delete();
    }
    final rappels = rappelBox.values.where((r) => r.animalId == id).toList();
    for (var r in rappels) {
      await r.delete();
    }
    final reproductions = reproductionBox.values.where((r) => r.animalId == id).toList();
    for (var r in reproductions) {
      await r.delete();
    }
    final transactions = transactionBox.values.where((t) => t.animalId == id).toList();
    for (var t in transactions) {
      await t.delete();
    }
    GoogleDriveService.autoSync();
  }

  static List<Animal> getTousLesAnimaux() {
    return animalBox.values.toList();
  }

  static Animal? getAnimal(String id) {
    return animalBox.get(id);
  }

  // CRUD Alimentation
  static Future<void> ajouterAlimentation(Alimentation alimentation) async {
    await alimentationBox.put(alimentation.id, alimentation);
    GoogleDriveService.autoSync();
  }

  static Future<void> modifierAlimentation(Alimentation alimentation) async {
    await alimentationBox.put(alimentation.id, alimentation);
    GoogleDriveService.autoSync();
  }

  static List<Alimentation> getAlimentationsParAnimal(String animalId) {
    return alimentationBox.values.where((a) => a.animalId == animalId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> supprimerAlimentation(String id) async {
    final alim = alimentationBox.get(id);
    if (alim?.transactionId != null) {
      await transactionBox.delete(alim!.transactionId!);
    }
    await alimentationBox.delete(id);
    GoogleDriveService.autoSync();
  }

  // CRUD Santé
  static Future<void> ajouterSante(Sante sante) async {
    await santeBox.put(sante.id, sante);
    GoogleDriveService.autoSync();
  }

  static List<Sante> getSantesParAnimal(String animalId) {
    return santeBox.values.where((s) => s.animalId == animalId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> supprimerSante(String id) async {
    await santeBox.delete(id);
    GoogleDriveService.autoSync();
  }

  // CRUD Croissance
  static Future<void> ajouterCroissance(Croissance croissance) async {
    await croissanceBox.put(croissance.id, croissance);
    GoogleDriveService.autoSync();
  }

  static List<Croissance> getCroissancesParAnimal(String animalId) {
    return croissanceBox.values.where((c) => c.animalId == animalId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static Future<void> supprimerCroissance(String id) async {
    await croissanceBox.delete(id);
    GoogleDriveService.autoSync();
  }

  // CRUD Reproduction
  static Future<void> ajouterReproduction(Reproduction reproduction) async {
    await reproductionBox.put(reproduction.id, reproduction);
    GoogleDriveService.autoSync();
  }

  static Future<void> updateReproduction(Reproduction reproduction) async {
    await reproductionBox.put(reproduction.id, reproduction);
    GoogleDriveService.autoSync();
  }

  static Future<void> deleteReproduction(String id) async {
    await reproductionBox.delete(id);
    GoogleDriveService.autoSync();
  }

  static Future<List<Reproduction>> getReproductions() async {
    return reproductionBox.values.toList()
      ..sort((a, b) => b.dateEvenement.compareTo(a.dateEvenement));
  }

  // CRUD Transactions
  static Future<void> ajouterTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
    GoogleDriveService.autoSync();
  }

  static Future<void> modifierTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
    GoogleDriveService.autoSync();
  }

  static Future<void> supprimerTransaction(String id) async {
    await transactionBox.delete(id);
    GoogleDriveService.autoSync();
  }

  static Future<List<Transaction>> getTransactions() async {
    return transactionBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // CRUD Rappels
  static Future<void> ajouterRappel(Rappel rappel) async {
    await rappelBox.put(rappel.id, rappel);
    GoogleDriveService.autoSync();
  }

  static Future<void> modifierRappel(Rappel rappel) async {
    await rappelBox.put(rappel.id, rappel);
    GoogleDriveService.autoSync();
  }

  static List<Rappel> getRappelsParAnimal(String animalId) {
    return rappelBox.values.where((r) => r.animalId == animalId).toList()
      ..sort((a, b) => a.dateRappel.compareTo(b.dateRappel));
  }

  static List<Rappel> getTousLesRappels() {
    return rappelBox.values.toList()
      ..sort((a, b) => a.dateRappel.compareTo(b.dateRappel));
  }

  static List<Rappel> getRappelsDuJour() {
    final now = DateTime.now();
    return rappelBox.values.where((r) {
      return !r.estComplete &&
          r.dateRappel.year == now.year &&
          r.dateRappel.month == now.month &&
          r.dateRappel.day == now.day;
    }).toList();
  }

  static List<Rappel> getRappelsEnRetard() {
    final now = DateTime.now();
    return rappelBox.values.where((r) {
      return !r.estComplete && r.dateRappel.isBefore(now);
    }).toList();
  }

  static List<Rappel> getRappelsAVenir() {
    final now = DateTime.now();
    final dans7Jours = now.add(const Duration(days: 7));
    return rappelBox.values.where((r) {
      return !r.estComplete &&
          r.dateRappel.isAfter(now) &&
          r.dateRappel.isBefore(dans7Jours);
    }).toList();
  }

  static Future<void> supprimerRappel(String id) async {
    await rappelBox.delete(id);
    GoogleDriveService.autoSync();
  }

  static Future<void> marquerRappelComplete(String id) async {
    final rappel = rappelBox.get(id);
    if (rappel != null) {
      rappel.estComplete = true;
      rappel.dateCompletion = DateTime.now();
      await rappelBox.put(id, rappel);

      // Si récurrent, créer le prochain rappel
      if (rappel.recurrent) {
        DateTime prochaineDateRappel;
        
        if (rappel.intervalleHeures != null) {
          prochaineDateRappel = rappel.dateRappel.add(Duration(hours: rappel.intervalleHeures!));
        } else if (rappel.intervalleJours != null) {
          prochaineDateRappel = rappel.dateRappel.add(Duration(days: rappel.intervalleJours!));
        } else {
          return;
        }

        // Vérifier si on dépasse la date de fin
        if (rappel.dateFin != null && prochaineDateRappel.isAfter(rappel.dateFin!)) {
          return;
        }

        final nouveauRappel = Rappel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          animalId: rappel.animalId,
          titre: rappel.titre,
          description: rappel.description,
          dateRappel: prochaineDateRappel,
          type: rappel.type,
          recurrent: true,
          intervalleJours: rappel.intervalleJours,
          intervalleHeures: rappel.intervalleHeures,
          dateFin: rappel.dateFin,
        );
        await ajouterRappel(nouveauRappel);
      }
      GoogleDriveService.autoSync();
    }
  }

  // Méthodes pour l'export
  static List<Animal> getAllAnimaux() => animalBox.values.toList();
  static List<Alimentation> getAllAlimentations() => alimentationBox.values.toList();
  static List<Sante> getAllSantes() => santeBox.values.toList();
  static List<Croissance> getAllCroissances() => croissanceBox.values.toList();
  static List<Reproduction> getAllReproductions() => reproductionBox.values.toList();
  static List<Transaction> getAllTransactions() => transactionBox.values.toList();

  static List<Rappel> getRappelsActifs() {
    return rappelBox.values.where((r) => !r.estComplete).toList();
  }

  static Rappel? getRappelById(String id) {
    return rappelBox.get(id);
  }
}
