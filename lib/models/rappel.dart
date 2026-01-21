import 'package:hive/hive.dart';

part 'rappel.g.dart';

@HiveType(typeId: 4)
class Rappel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String animalId;

  @HiveField(2)
  late String titre;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late DateTime dateRappel;

  @HiveField(5)
  late String type; // vaccination, vermifuge, visite_veterinaire, soin, autre

  @HiveField(6)
  late bool estComplete;

  @HiveField(7)
  DateTime? dateCompletion;

  @HiveField(8)
  bool recurrent;

  @HiveField(9)
  int? intervalleJours; // Pour les rappels récurrents

  @HiveField(10)
  int? intervalleHeures; // Pour les rappels en heures

  @HiveField(11)
  DateTime? dateFin; // Date de fin pour les rappels récurrents

  Rappel({
    required this.id,
    required this.animalId,
    required this.titre,
    required this.description,
    required this.dateRappel,
    required this.type,
    this.estComplete = false,
    this.dateCompletion,
    this.recurrent = false,
    this.intervalleJours,
    this.intervalleHeures,
    this.dateFin,
  });

  bool get estEnRetard {
    return !estComplete && dateRappel.isBefore(DateTime.now());
  }

  bool get estAujourdhui {
    final now = DateTime.now();
    return dateRappel.year == now.year &&
        dateRappel.month == now.month &&
        dateRappel.day == now.day;
  }

  bool get estCetteSemaine {
    final now = DateTime.now();
    final finSemaine = now.add(const Duration(days: 7));
    return dateRappel.isAfter(now) && dateRappel.isBefore(finSemaine);
  }
}
