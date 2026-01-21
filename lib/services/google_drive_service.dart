import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../models/models.dart';

class GoogleDriveService {
  static const _scopes = [
    drive.DriveApi.driveFileScope,
    'https://www.googleapis.com/auth/drive.file'
  ];
  static const _syncEnabledKey = 'google_drive_sync_enabled';
  static const _authStateKey = 'google_drive_auth_state';
  
  static GoogleSignIn? _googleSignIn;
  static drive.DriveApi? _driveApi;
  static GoogleSignInAccount? _currentUser;
  static bool _isInitialized = false;

  static GoogleSignIn get _getGoogleSignIn {
    _googleSignIn ??= GoogleSignIn(
      scopes: _scopes,
    );
    return _googleSignIn!;
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _restoreAuthState();
    _isInitialized = true;
  }

  static Future<bool> get isSyncEnabled async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_authStateKey) ?? false;
    if (isEnabled && _currentUser == null) {
      _currentUser = _getGoogleSignIn.currentUser;
      if (_currentUser != null) {
        final authHeaders = await _currentUser!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _driveApi = drive.DriveApi(authenticateClient);
      }
    }
    return isEnabled && _currentUser != null;
  }

  static Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authStateKey, enabled);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authStateKey, false);
  }

  static Future<void> disconnect() async {
    await _disconnect();
  }

  static Future<void> _restoreAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool(_authStateKey) ?? false;
    
    if (isAuthenticated) {
      try {
        _currentUser = await _getGoogleSignIn.signInSilently();
        if (_currentUser != null) {
          final authHeaders = await _currentUser!.authHeaders;
          final authenticateClient = GoogleAuthClient(authHeaders);
          _driveApi = drive.DriveApi(authenticateClient);
        } else {
          await prefs.setBool(_authStateKey, false);
        }
      } catch (e) {
        await prefs.setBool(_authStateKey, false);
      }
    }
  }

  static Future<bool> syncData() async {
    if (!await isSyncEnabled || _driveApi == null) {
      print('Sync non activé ou DriveApi null');
      return false;
    }
    
    try {
      final data = await _exportAllData();
      await _uploadToGoogleDrive(data);
      print('Sauvegarde réussie');
      return true;
    } catch (e) {
      print('Erreur sync: $e');
      return false;
    }
  }

  static Future<void> autoSync() async {
    if (await isSyncEnabled) {
      syncData();
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
    try {
      final jsonData = jsonEncode(data);
      final fileName = 'umuragizi_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      
      final driveFile = drive.File()
        ..name = fileName;
      
      final media = drive.Media(
        Stream.fromIterable([utf8.encode(jsonData)]),
        jsonData.length,
      );
      
      final result = await _driveApi!.files.create(driveFile, uploadMedia: media);
      print('Fichier uploadé avec ID: ${result.id}');
    } catch (e) {
      print('Erreur upload: $e');
      rethrow;
    }
  }

  static Future<bool> restoreData() async {
    if (!await isSyncEnabled || _driveApi == null) return false;
    
    try {
      final files = await _driveApi!.files.list(
        q: "name contains 'umuragizi_backup'",
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
    // Merger les données au lieu de les écraser
    await _mergeAnimals(data['animals'] as List);
    await _mergeAlimentations(data['alimentations'] as List);
    await _mergeSantes(data['santes'] as List);
    await _mergeCroissances(data['croissances'] as List);
    await _mergeRappels(data['rappels'] as List);
  }

  static Future<void> _mergeAnimals(List animalsList) async {
    final existingIds = DatabaseService.getAllAnimaux().map((a) => a.id).toSet();
    
    for (final animalData in animalsList) {
      if (!existingIds.contains(animalData['id'])) {
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
    }
  }

  static Future<void> _mergeAlimentations(List alimentationsList) async {
    final existingIds = DatabaseService.getAllAlimentations().map((a) => a.id).toSet();
    
    for (final alimentationData in alimentationsList) {
      if (!existingIds.contains(alimentationData['id'])) {
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
    }
  }

  static Future<void> _mergeSantes(List santesList) async {
    final existingIds = DatabaseService.getAllSantes().map((s) => s.id).toSet();
    
    for (final santeData in santesList) {
      if (!existingIds.contains(santeData['id'])) {
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
    }
  }

  static Future<void> _mergeCroissances(List croissancesList) async {
    final existingIds = DatabaseService.getAllCroissances().map((c) => c.id).toSet();
    
    for (final croissanceData in croissancesList) {
      if (!existingIds.contains(croissanceData['id'])) {
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
    }
  }

  static Future<void> _mergeRappels(List rappelsList) async {
    final existingIds = DatabaseService.getTousLesRappels().map((r) => r.id).toSet();
    
    for (final rappelData in rappelsList) {
      if (!existingIds.contains(rappelData['id'])) {
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