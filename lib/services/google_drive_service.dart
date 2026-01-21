import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database_service.dart';
import '../models/models.dart';

class GoogleDriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];
  static const _syncEnabledKey = 'google_drive_sync_enabled';
  
  static GoogleSignIn? _googleSignIn;
  static drive.DriveApi? _driveApi;
  static GoogleSignInAccount? _currentUser;

  static GoogleSignIn get _getGoogleSignIn {
    _googleSignIn ??= GoogleSignIn(
      scopes: _scopes,
    );
    return _googleSignIn!;
  }

  static Future<bool> get isSyncEnabled async {
    final box = await Hive.openBox('settings');
    final isEnabled = box.get(_syncEnabledKey, defaultValue: false);
    if (isEnabled) {
      _currentUser = _getGoogleSignIn.currentUser;
      return _currentUser != null;
    }
    return false;
  }

  static Future<void> setSyncEnabled(bool enabled) async {
    final box = await Hive.openBox('settings');
    await box.put(_syncEnabledKey, enabled);
    if (!enabled) {
      await _disconnect();
    }
  }

  static Future<bool> authenticate() async {
    try {
      _currentUser = await _getGoogleSignIn.signIn();
      if (_currentUser != null) {
        final authHeaders = await _currentUser!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _driveApi = drive.DriveApi(authenticateClient);
        await setSyncEnabled(true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _disconnect() async {
    await _getGoogleSignIn.signOut();
    _driveApi = null;
    _currentUser = null;
    final box = await Hive.openBox('settings');
    await box.put(_syncEnabledKey, false);
  }

  static Future<bool> syncData() async {
    if (!await isSyncEnabled || _driveApi == null) return false;
    
    try {
      final data = await _exportAllData();
      await _uploadToGoogleDrive(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> _exportAllData() async {
    final animals = DatabaseService.getAllAnimaux().map((a) => {
      'id': a.id,
      'nom': a.nom,
      'espece': a.espece,
      'race': a.race,
      'sexe': a.sexe,
      'dateNaissance': a.dateNaissance.toIso8601String(),
      'photoPath': a.photoPath,
      'photoBase64': a.photoBase64,
      'identifiant': a.identifiant,
      'dateAjout': a.dateAjout.toIso8601String(),
      'notes': a.notes,
      'mereId': a.mereId,
      'prixAchat': a.prixAchat,
    }).toList();
    
    final alimentations = DatabaseService.getAllAlimentations().map((a) => {
      'id': a.id,
      'animalId': a.animalId,
      'date': a.date.toIso8601String(),
      'typeAliment': a.typeAliment,
      'quantite': a.quantite,
      'unite': a.unite,
      'notes': a.notes,
      'prixUnitaire': a.prixUnitaire,
    }).toList();
    
    final santes = DatabaseService.getAllSantes().map((s) => {
      'id': s.id,
      'animalId': s.animalId,
      'date': s.date.toIso8601String(),
      'type': s.type,
      'description': s.description,
      'veterinaire': s.veterinaire,
      'cout': s.cout,
      'notes': s.notes,
    }).toList();
    
    final croissances = DatabaseService.getAllCroissances().map((c) => {
      'id': c.id,
      'animalId': c.animalId,
      'date': c.date.toIso8601String(),
      'poids': c.poids,
      'taille': c.taille,
      'notes': c.notes,
    }).toList();
    
    final rappels = DatabaseService.getTousLesRappels().map((r) => {
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
    }).toList();
    
    return {
      'animals': animals,
      'alimentations': alimentations,
      'santes': santes,
      'croissances': croissances,
      'rappels': rappels,
      'export_date': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> _uploadToGoogleDrive(Map<String, dynamic> data) async {
    final jsonData = jsonEncode(data);
    final fileName = 'smart_farm_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    
    final driveFile = drive.File()
      ..name = fileName
      ..parents = ['appDataFolder'];
    
    final media = drive.Media(
      Stream.fromIterable([utf8.encode(jsonData)]),
      jsonData.length,
    );
    
    await _driveApi!.files.create(driveFile, uploadMedia: media);
  }

  static Future<bool> restoreData() async {
    if (!await isSyncEnabled || _driveApi == null) return false;
    
    try {
      final files = await _driveApi!.files.list(
        q: "parents in 'appDataFolder' and name contains 'smart_farm_backup'",
        orderBy: 'createdTime desc',
        pageSize: 1,
      );
      
      if (files.files?.isEmpty ?? true) return false;
      
      final fileId = files.files!.first.id!;
      final media = await _driveApi!.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      
      final dataBytes = <int>[];
      await for (final chunk in media.stream) {
        dataBytes.addAll(chunk);
      }
      
      final jsonData = utf8.decode(dataBytes);
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      await _importData(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _importData(Map<String, dynamic> data) async {
    await DatabaseService.animalBox.clear();
    await DatabaseService.alimentationBox.clear();
    await DatabaseService.santeBox.clear();
    await DatabaseService.croissanceBox.clear();
    await DatabaseService.rappelBox.clear();
    
    for (final animalData in data['animals'] as List) {
      final animal = Animal(
        id: animalData['id'],
        nom: animalData['nom'],
        espece: animalData['espece'],
        race: animalData['race'],
        sexe: animalData['sexe'],
        dateNaissance: DateTime.parse(animalData['dateNaissance']),
        photoPath: animalData['photoPath'],
        photoBase64: animalData['photoBase64'],
        identifiant: animalData['identifiant'],
        dateAjout: DateTime.parse(animalData['dateAjout']),
        notes: animalData['notes'],
        mereId: animalData['mereId'],
        prixAchat: animalData['prixAchat']?.toDouble(),
      );
      await DatabaseService.ajouterAnimal(animal);
    }
    
    for (final alimentationData in data['alimentations'] as List) {
      final alimentation = Alimentation(
        id: alimentationData['id'],
        animalId: alimentationData['animalId'],
        date: DateTime.parse(alimentationData['date']),
        typeAliment: alimentationData['typeAliment'],
        quantite: alimentationData['quantite'].toDouble(),
        unite: alimentationData['unite'],
        notes: alimentationData['notes'],
        prixUnitaire: alimentationData['prixUnitaire']?.toDouble(),
      );
      await DatabaseService.ajouterAlimentation(alimentation);
    }
    
    for (final santeData in data['santes'] as List) {
      final sante = Sante(
        id: santeData['id'],
        animalId: santeData['animalId'],
        date: DateTime.parse(santeData['date']),
        type: santeData['type'],
        description: santeData['description'],
        veterinaire: santeData['veterinaire'],
        cout: santeData['cout']?.toDouble(),
        notes: santeData['notes'],
      );
      await DatabaseService.ajouterSante(sante);
    }
    
    for (final croissanceData in data['croissances'] as List) {
      final croissance = Croissance(
        id: croissanceData['id'],
        animalId: croissanceData['animalId'],
        date: DateTime.parse(croissanceData['date']),
        poids: croissanceData['poids'].toDouble(),
        taille: croissanceData['taille']?.toDouble(),
        notes: croissanceData['notes'],
      );
      await DatabaseService.ajouterCroissance(croissance);
    }
    
    for (final rappelData in data['rappels'] as List) {
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

class GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;

  GoogleAuthClient(this._headers);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers.addAll(_headers);
    return request.send();
  }
}