import 'package:hive/hive.dart';

part 'production.g.dart';

@HiveType(typeId: 7)
class Production extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String animalId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late String type; // 'Lait', 'Oeufs', 'Laine', 'Autre'

  @HiveField(4)
  late double quantite;

  @HiveField(5)
  late String unite; // 'L', 'unités', 'kg'

  @HiveField(6)
  double? prixUnitaire;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? transactionId;

  Production({
    required this.id,
    required this.animalId,
    required this.date,
    required this.type,
    required this.quantite,
    required this.unite,
    this.prixUnitaire,
    this.notes,
    this.transactionId,
  });

  double get valeurTotale => (prixUnitaire ?? 0) * quantite;
}
