import 'package:hive/hive.dart';

part 'animal.g.dart';

@HiveType(typeId: 0)
class Animal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nom;

  @HiveField(2)
  late String espece;

  @HiveField(3)
  late String race;

  @HiveField(4)
  late String sexe;

  @HiveField(5)
  late DateTime dateNaissance;

  @HiveField(6)
  String? photoPath;

  @HiveField(10)
  String? photoBase64; // Image en base64 pour synchronisation/exportation

  @HiveField(7)
  late String identifiant;

  @HiveField(8)
  late DateTime dateAjout;

  @HiveField(9)
  String? notes;

  @HiveField(11)
  String? mereId;

  @HiveField(12)
  double? prixAchat;

  Animal({
    required this.id,
    required this.nom,
    required this.espece,
    required this.race,
    required this.sexe,
    required this.dateNaissance,
    this.photoPath,
    this.photoBase64,
    required this.identifiant,
    required this.dateAjout,
    this.notes,
    this.mereId,
    this.prixAchat,
  });

  int get ageEnMois {
    final now = DateTime.now();
    return (now.year - dateNaissance.year) * 12 +
        (now.month - dateNaissance.month);
  }

  String get ageFormate {
    final mois = ageEnMois;
    if (mois < 12) {
      return '$mois mois';
    } else {
      final annees = mois ~/ 12;
      final moisRestants = mois % 12;
      if (moisRestants == 0) {
        return '$annees an${annees > 1 ? 's' : ''}';
      }
      return '$annees an${annees > 1 ? 's' : ''} et $moisRestants mois';
    }
  }
}
