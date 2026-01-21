import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class ExportImportService {
  /// Exporte toutes les données en JSON avec les images en base64
  static Future<String> exportData() async {
    final data = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'animaux': DatabaseService.getAllAnimaux().map((a) => {
        'id': a.id,
        'nom': a.nom,
        'espece': a.espece,
        'race': a.race,
        'sexe': a.sexe,
        'dateNaissance': a.dateNaissance.toIso8601String(),
        'photoBase64': a.photoBase64,
        'identifiant': a.identifiant,
        'dateAjout': a.dateAjout.toIso8601String(),
        'notes': a.notes,
      }).toList(),
      'alimentations': DatabaseService.getAllAlimentations().map((a) => {
        'id': a.id,
        'animalId': a.animalId,
        'typeAliment': a.typeAliment,
        'quantite': a.quantite,
        'unite': a.unite,
        'date': a.date.toIso8601String(),
        'notes': a.notes,
      }).toList(),
      'santes': DatabaseService.getAllSantes().map((s) => {
        'id': s.id,
        'animalId': s.animalId,
        'type': s.type,
        'description': s.description,
        'date': s.date.toIso8601String(),
        'veterinaire': s.veterinaire,
        'notes': s.notes,
      }).toList(),
      'croissances': DatabaseService.getAllCroissances().map((c) => {
        'id': c.id,
        'animalId': c.animalId,
        'poids': c.poids,
        'taille': c.taille,
        'date': c.date.toIso8601String(),
        'etatPhysique': c.etatPhysique,
        'notes': c.notes,
      }).toList(),
      'rappels': DatabaseService.getTousLesRappels().map((r) => {
        'id': r.id,
        'animalId': r.animalId,
        'titre': r.titre,
        'description': r.description,
        'dateRappel': r.dateRappel.toIso8601String(),
        'type': r.type,
        'estComplete': r.estComplete,
        'dateCompletion': r.dateCompletion?.toIso8601String(),
        'recurrent': r.recurrent,
        'intervalleJours': r.intervalleJours,
        'intervalleHeures': r.intervalleHeures,
        'dateFin': r.dateFin?.toIso8601String(),
      }).toList(),
    };

    return jsonEncode(data);
  }

  /// Sauvegarde l'export dans un fichier
  static Future<File> saveExportToFile() async {
    final jsonData = await exportData();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/umuragizi_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonData);
    return file;
  }

  /// Importe les données depuis un JSON
  static Future<void> importData(String jsonData) async {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;
    
    // Importer les animaux
    if (data['animaux'] != null) {
      for (var animalData in data['animaux']) {
        final animal = Animal(
          id: animalData['id'],
          nom: animalData['nom'],
          espece: animalData['espece'],
          race: animalData['race'],
          sexe: animalData['sexe'],
          dateNaissance: DateTime.parse(animalData['dateNaissance']),
          photoBase64: animalData['photoBase64'],
          identifiant: animalData['identifiant'],
          dateAjout: DateTime.parse(animalData['dateAjout']),
          notes: animalData['notes'],
        );
        await DatabaseService.ajouterAnimal(animal);
      }
    }

    // Importer les alimentations
    if (data['alimentations'] != null) {
      for (var alimData in data['alimentations']) {
        final alim = Alimentation(
          id: alimData['id'],
          animalId: alimData['animalId'],
          typeAliment: alimData['typeAliment'],
          quantite: alimData['quantite'],
          unite: alimData['unite'],
          date: DateTime.parse(alimData['date']),
          notes: alimData['notes'],
        );
        await DatabaseService.ajouterAlimentation(alim);
      }
    }

    // Importer les données de santé
    if (data['santes'] != null) {
      for (var santeData in data['santes']) {
        final sante = Sante(
          id: santeData['id'],
          animalId: santeData['animalId'],
          type: santeData['type'],
          description: santeData['description'],
          date: DateTime.parse(santeData['date']),
          veterinaire: santeData['veterinaire'],
          notes: santeData['notes'],
        );
        await DatabaseService.ajouterSante(sante);
      }
    }

    // Importer les croissances
    if (data['croissances'] != null) {
      for (var croissanceData in data['croissances']) {
        final croissance = Croissance(
          id: croissanceData['id'],
          animalId: croissanceData['animalId'],
          poids: croissanceData['poids'],
          taille: croissanceData['taille'],
          date: DateTime.parse(croissanceData['date']),
          etatPhysique: croissanceData['etatPhysique'],
          notes: croissanceData['notes'],
        );
        await DatabaseService.ajouterCroissance(croissance);
      }
    }

    // Importer les rappels
    if (data['rappels'] != null) {
      for (var rappelData in data['rappels']) {
        final rappel = Rappel(
          id: rappelData['id'],
          animalId: rappelData['animalId'],
          titre: rappelData['titre'],
          description: rappelData['description'],
          dateRappel: DateTime.parse(rappelData['dateRappel']),
          type: rappelData['type'],
          estComplete: rappelData['estComplete'],
          dateCompletion: rappelData['dateCompletion'] != null 
              ? DateTime.parse(rappelData['dateCompletion']) 
              : null,
          recurrent: rappelData['recurrent'],
          intervalleJours: rappelData['intervalleJours'],
          intervalleHeures: rappelData['intervalleHeures'],
          dateFin: rappelData['dateFin'] != null 
              ? DateTime.parse(rappelData['dateFin']) 
              : null,
        );
        await DatabaseService.ajouterRappel(rappel);
      }
    }
  }

  /// Importe depuis un fichier
  static Future<void> importFromFile(File file) async {
    final jsonData = await file.readAsString();
    await importData(jsonData);
  }
}
