import 'package:hive/hive.dart';

part 'sante.g.dart';

@HiveType(typeId: 2)
class Sante extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String animalId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late String type; // vaccination, traitement, maladie, visite

  @HiveField(4)
  late String description;

  @HiveField(5)
  String? medicament;

  @HiveField(6)
  String? veterinaire;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  double? cout;

  @HiveField(9)
  bool estPaye;

  Sante({
    required this.id,
    required this.animalId,
    required this.date,
    required this.type,
    required this.description,
    this.medicament,
    this.veterinaire,
    this.notes,
    this.cout,
    this.estPaye = true,
  });
}

@HiveType(typeId: 3)
class Croissance extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String animalId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late double poids;

  @HiveField(4)
  double? taille;

  @HiveField(5)
  String? etatPhysique; // excellent, bon, moyen, faible

  @HiveField(6)
  String? notes;

  Croissance({
    required this.id,
    required this.animalId,
    required this.date,
    required this.poids,
    this.taille,
    this.etatPhysique,
    this.notes,
  });
}
