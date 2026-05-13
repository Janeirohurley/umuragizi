import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Builds the system prompt with current farm data.
  Future<String> _buildSystemPrompt() async {
    final animals = DatabaseService.getTousLesAnimaux();
    // final rappelsActifs = DatabaseService.getRappelsActifs(); // not used
    final rappelsEnRetard = DatabaseService.getRappelsEnRetard();
    final rappelsJour = DatabaseService.getRappelsDuJour();
    final rappelsSemaine = DatabaseService.getRappelsAVenir();
    final allSantes = DatabaseService.getAllSantes();
    final allCroissances = DatabaseService.getAllCroissances();
    final allGenetics = DatabaseService.getAllGeneticInfos();

    // Prepare maps for quick lookups
    final animalMap = {for (var a in animals) a.id: a};

    // Format animals list
    final animalsList = animals.map((a) {
      final age = a.ageFormate;
      return '• ${a.identifiant}: ${a.nom} (${a.espece}, ${a.race}, ${a.sexe}, âgé de $age, statut: ${a.statut})';
    }).join('\n');

    // Format tasks (rappels)
    final tasksList = <String>[];
    for (var r in rappelsEnRetard) {
      final animal = animalMap[r.animalId];
      final animalName = animal?.nom ?? 'Inconnu';
      tasksList.add('• [EN RETARD] ${r.titre} pour $animalName — Date: ${_formatDate(r.dateRappel)} — ${r.description}');
    }
    for (var r in rappelsJour) {
      final animal = animalMap[r.animalId];
      final animalName = animal?.nom ?? 'Inconnu';
      tasksList.add('• [AUJOURD\'HUI] ${r.titre} pour $animalName — ${r.description}');
    }
    for (var r in rappelsSemaine) {
      final animal = animalMap[r.animalId];
      final animalName = animal?.nom ?? 'Inconnu';
      tasksList.add('• [À VENIR] ${r.titre} pour $animalName — Date: ${_formatDate(r.dateRappel)} — ${r.description}');
    }
    final tasksStr = tasksList.isEmpty ? 'Aucune tâche planifiée.' : tasksList.join('\n');

    // Format health records (latest 10)
    final recentSantes = allSantes.take(10).toList();
    final healthRecords = recentSantes.map((s) {
      final animal = animalMap[s.animalId];
      final animalName = animal?.nom ?? 'Inconnu';
      return '• ${_formatDate(s.date)} — $animalName — ${s.type}: ${s.description}${s.medicament != null ? ' (Médicament: ${s.medicament})' : ''}';
    }).join('\n');

    // Format growth records (latest 15)
    final recentCroissances = allCroissances.take(15).toList();
    final growthRecords = recentCroissances.map((c) {
      final animal = animalMap[c.animalId];
      final animalName = animal?.nom ?? 'Inconnu';
      return '• ${_formatDate(c.date)} — $animalName — Poids: ${c.poids} kg${c.taille != null ? ', Taille: ${c.taille} cm' : ''}${c.etatPhysique != null ? ', État: ${c.etatPhysique}' : ''}';
    }).join('\n');

    // Format genetics
    final geneticsRecords = allGenetics.map((g) {
      final animal = animalMap[g.animalId];
      final animalName = animal?.nom ?? 'Inconnu';
      return '• $animalName — EBV: ${g.ebv.toStringAsFixed(2)}, Coefficient de consanguinité: ${g.inbreedingCoefficient.toStringAsFixed(4)}';
    }).join('\n');

    // Active alerts
    final alertsList = <String>[];
    if (rappelsEnRetard.isNotEmpty) {
      alertsList.add('• ${rappelsEnRetard.length} rappel(s) en retard nécessitent une attention immédiate.');
    }
    final activeAlerts = alertsList.isEmpty ? 'Aucune alerte active.' : alertsList.join('\n');

    // Farm stats
    final totalAnimals = animals.length;
    final actifs = animals.where((a) => a.statut == 'Actif').length;
    final parEspece = <String, int>{};
    for (var a in animals) {
      parEspece[a.espece] = (parEspece[a.espece] ?? 0) + 1;
    }
    final especeStr = parEspece.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    final tachesEnRetard = rappelsEnRetard.length;

    final farmStats = '''
Total animaux: $totalAnimals (actifs: $actifs)
Par espèce: $especeStr
Tâches en retard: $tachesEnRetard
''';

    // Load template (hardcoded)
    const template = '''Tu es **Umuragizi AI**, un assistant vétérinaire et agropastoral intelligent intégré dans 
l'application mobile Umuragizi. Tu es le partenaire de confiance de l'éleveur au quotidien.
Tu parles principalement en français, mais tu t'adaptes si l'éleveur utilise le Kirundi, 
le Swahili ou l'anglais.

---

## 🎯 TON RÔLE PRINCIPAL

Tu aides l'éleveur à :
- Surveiller et prédire l'état de santé de chaque animal
- Analyser les images d'animaux pour détecter des anomalies visibles
- Interpréter les données de croissance et donner des recommandations
- Gérer le calendrier des tâches (vaccinations, vermifugations, saillie, etc.)
- Comprendre les lignées génétiques et optimiser la reproduction
- Recevoir des alertes intelligentes et y répondre
- Prendre de meilleures décisions grâce à l'analyse des données historiques

---

## 📊 DONNÉES CONTEXTUELLES DE LA FERME

Voici les données actuelles de la ferme de l'éleveur extraites de la base de données locale.
Utilise ces informations comme base de toutes tes réponses. Ne les ignore jamais.

### Animaux enregistrés :
{animals_list}

### Tâches planifiées :
{tasks_list}

### Historique de santé récent :
{health_records}

### Historique de croissance :
{growth_records}

### Données de reproduction / génétique :
{genetics_records}

### Alertes actives :
{active_alerts}

### Statistiques globales de la ferme :
{farm_stats}

---

## 🧠 TES CAPACITÉS D'ANALYSE

### 1. Analyse de santé
- À partir des symptômes décrits ou des images, tu identifies les maladies probables
- Tu proposes un diagnostic différentiel (plusieurs hypothèses classées par probabilité)
- Tu recommandes des traitements adaptés au contexte local (médicaments disponibles en Afrique de l'Est)
- Tu signales quand une consultation vétérinaire urgente est nécessaire
- Maladies courantes que tu surveilles : Fièvre aphteuse, Brucellose, Charbon, Trypanosomiase, 
  Newcastle, Coccidiose, Dermatophilose, Mammite, Parasitoses internes/externes

### 2. Analyse par image
- Quand l'éleveur envoie une photo d'un animal, tu analyses :
  * L'état corporel visible (maigreur, gonflement, blessures, posture anormale)
  * La couleur et l'état des muqueuses si visibles
  * Des lésions cutanées, ectoparasites, boiteries
  * L'état général et le comportement perceptible
- Tu décris précisément ce que tu observes avant de conclure
- Tu demandes des angles supplémentaires si nécessaire

### 3. Prédiction et anticipation
- Tu analyses les tendances de croissance pour détecter les retards ou anomalies
- Tu prédis les prochaines périodes de chaleur / saillie selon les cycles enregistrés
- Tu anticipes les besoins en alimentation selon le stade physiologique
- Tu signales les vaccinations et traitements preventifs à venir
- Tu détectes les patterns de maladie récurrents dans le troupeau

### 4. Analyse génétique et reproduction
- Tu expliques les performances de reproduction de chaque femelle
- Tu conseilles sur les croisements pour améliorer des traits spécifiques (croissance, lait, résistance)
- Tu suis les gestations et rappelles les dates clés (mise-bas prévue, sevrage, etc.)
- Tu identifies les animaux les moins performants génétiquement

### 5. Gestion des tâches
- Tu rappelles les tâches urgentes et en retard
- Tu suggères de nouvelles tâches basées sur l'état des animaux
- Tu aides à planifier le calendrier sanitaire annuel
- Tu priorises les tâches selon leur impact sur la santé et la rentabilité

---

## 💬 STYLE DE COMMUNICATION

- **Clarté absolue** : Parle simplement, comme à un éleveur de terrain, pas à un scientifique
- **Structuré** : Utilise des listes, des emojis pertinents et des titres courts
- **Empathique** : L'éleveur peut être inquiet pour ses animaux. Sois rassurant mais honnête
- **Proactif** : Ne réponds pas seulement à la question, signale aussi ce que tu remarques dans les données
- **Concis** : Pas de longs discours. Va à l'essentiel. Propose des détails si demandé
- **Local** : Utilise des exemples et références adaptés à l'élevage en Afrique centrale/orientale

Exemples de ton de réponse :
✅ "La vache N°12 montre une baisse de poids de 8% ce mois-ci. C'est préoccupant. Vérifions d'abord son alimentation et son état parasitaire."
✅ "D'après l'image, je vois une lésion sur le flanc gauche. Ça ressemble à de la dermatophilose. Voici ce qu'il faut faire immédiatement..."
✅ "Bonne nouvelle : 3 brebis devraient entrer en chaleur dans les 5 prochains jours selon leurs cycles. Prépare le bélier."

---

## ⚠️ RÈGLES IMPORTANTES

1. **Sécurité animale en priorité** : Si tu détectes une situation critique (animal en danger de mort, 
   maladie très contagieuse), dis-le clairement et immédiatement en PREMIER.

2. **Honnêteté sur tes limites** : Si tu n'es pas sûr d'un diagnostic, dis-le. 
   Ne confabule jamais de données que tu n'as pas.

3. **Respect des données locales** : Base-toi TOUJOURS sur les données fournies par la base de données. 
   Ne suppose pas ce que tu ne sais pas sur la ferme.

4. **Pas de remplacement vétérinaire** : Pour les cas graves ou incertains, 
   recommande toujours de consulter un vétérinaire en plus de tes conseils.

5. **Confidentialité** : Les données de la ferme sont privées. 
   Ne les partage jamais, ne les cite que dans le contexte de la conversation.

---

## 📋 FORMAT DE RÉPONSE RECOMMANDÉ

Pour les questions simples → Réponse directe en 2-3 phrases max.

Pour les analyses → Structure :
**🔍 Observation** : Ce que tu constates
**💡 Diagnostic probable** : Ton analyse
**✅ Action recommandée** : Ce qu'il faut faire maintenant
**📅 Suivi** : Ce qu'il faut surveiller ensuite

Pour les alertes urgentes → Commence toujours par 🚨

---

## 🌍 CONTEXTE GÉOGRAPHIQUE ET CLIMATIQUE

L'élevage se situe en Afrique centrale/orientale (Burundi et région des Grands Lacs).
Tiens compte de :
- Les saisons des pluies et sèches et leur impact sur les pâturages et maladies
- La disponibilité limitée de certains médicaments en zone rurale  
- Les pratiques d'élevage traditionnel et semi-intensif
- Les espèces locales : bovins (Ankole, croisés), caprins, ovins, porcins, volailles

Commence chaque session en saluant l'éleveur chaleureusement et en résumant 
en 2-3 points les informations les plus importantes du moment dans sa ferme.''';

    return template
        .replaceAll('{animals_list}', animalsList.isNotEmpty ? animalsList : 'Aucun animal enregistré.')
        .replaceAll('{tasks_list}', tasksStr)
        .replaceAll('{health_records}', healthRecords.isNotEmpty ? healthRecords : 'Aucun enregistrement de santé récent.')
        .replaceAll('{growth_records}', growthRecords.isNotEmpty ? growthRecords : 'Aucun enregistrement de croissance.')
        .replaceAll('{genetics_records}', geneticsRecords.isNotEmpty ? geneticsRecords : 'Aucune donnée génétique disponible.')
        .replaceAll('{active_alerts}', activeAlerts)
        .replaceAll('{farm_stats}', farmStats);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Adds a user message (text or image) to the chat and gets AI response.
  /// If [imagePath] is provided, the image will be included in the request.
  Future<void> sendMessage({
    required String text,
    String? imagePath,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Add user message to displayed list
      final userMsg = ChatMessage(
        isUser: true,
        type: imagePath != null ? MessageType.image : MessageType.text,
        text: text,
        filePath: imagePath,
        time: DateTime.now(),
      );
      _messages.add(userMsg);

      // Get API key
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('openai_api_key');
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Clé API OpenAI non configurée. Veuillez la définir dans les paramètres.');
      }

      // Build messages for API
      final systemPrompt = await _buildSystemPrompt();
      final apiMessages = <Map<String, dynamic>>[
        {'role': 'system', 'content': systemPrompt},
      ];

      // Add conversation history
      for (var msg in _messages) {
        if (msg.isUser) {
          if (msg.type == MessageType.image && msg.filePath != null) {
            final bytes = await File(msg.filePath!).readAsBytes();
            final base64Image = base64Encode(bytes);
            final dataUrl = 'data:image/jpeg;base64,$base64Image';
            apiMessages.add({
              'role': 'user',
              'content': [
                {'type': 'text', 'text': msg.text ?? '(image sans description)'},
                {'type': 'image_url', 'image_url': {'url': dataUrl}},
              ],
            });
          } else {
            // text or audio (audio will be sent as generic text if any)
            final content = msg.text ?? '(message vide)';
            apiMessages.add({'role': 'user', 'content': content});
          }
        } else {
          // assistant
          apiMessages.add({'role': 'assistant', 'content': msg.text});
        }
      }

      // Call AI
      final model = prefs.getString('ai_model') ?? 'gpt-4';
      final responseText = await AIService.getResponse(
        apiKey: apiKey,
        messages: apiMessages,
        model: model,
      );

      // Add assistant response
      final assistantMsg = ChatMessage(
        isUser: false,
        type: MessageType.text,
        text: responseText,
        time: DateTime.now(),
      );
      _messages.add(assistantMsg);
    } catch (e) {
      _error = e.toString();
      // Show error as assistant message
      _messages.add(ChatMessage(
        isUser: false,
        type: MessageType.text,
        text: '⚠️ Erreur: ${e.toString()}',
        time: DateTime.now(),
      ));
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a non-AI user message (e.g., audio recording) directly to chat.
  void addNonAIMessage({
    required String text,
    MessageType type = MessageType.text,
    String? filePath,
  }) {
    _messages.add(ChatMessage(
      isUser: true,
      type: type,
      text: text,
      filePath: filePath,
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  /// Sends an initial greeting if the chat is empty.
  Future<void> initializeGreeting() async {
    if (_messages.isNotEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('openai_api_key');
      if (apiKey == null || apiKey.isEmpty) return;

      final systemPrompt = await _buildSystemPrompt();
      final apiMessages = <Map<String, dynamic>>[
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': 'Bonjour'},
      ];

      final model = prefs.getString('ai_model') ?? 'gpt-4';
      final responseText = await AIService.getResponse(
        apiKey: apiKey,
        messages: apiMessages,
        model: model,
      );

      _messages.add(ChatMessage(
        isUser: false,
        type: MessageType.text,
        text: responseText,
        time: DateTime.now(),
      ));
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }
}
