import 'package:hive/hive.dart';

part 'alimentation.g.dart';

@HiveType(typeId: 1)
class Alimentation extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String animalId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late String typeAliment;

  @HiveField(4)
  late double quantite;

  @HiveField(5)
  late String unite;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  double? prixUnitaire;

  Alimentation({
    required this.id,
    required this.animalId,
    required this.date,
    required this.typeAliment,
    required this.quantite,
    required this.unite,
    this.notes,
    this.prixUnitaire,
  });

  double get coutTotal => (prixUnitaire ?? 0) * quantite;
}
