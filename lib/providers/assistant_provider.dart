import 'package:flutter/material.dart';

class AssistantProvider extends ChangeNotifier {
  bool _showSupportBubble = false;

  // Getter pour lire la valeur
  bool get showSupportBubble => _showSupportBubble;

  // Fonction pour changer l'état
  void setBubbleVisible(bool visible) {
    _showSupportBubble = visible;
    notifyListeners(); // C'est ici que la magie opère : l'UI se rafraîchit
  }

  // Vous pouvez même y mettre votre logique de Timer
  void lancerSequenceBienvenue() async {
    await Future.delayed(const Duration(seconds: 2));
    setBubbleVisible(true);

    await Future.delayed(const Duration(seconds: 4));
    setBubbleVisible(false);
  }
}
