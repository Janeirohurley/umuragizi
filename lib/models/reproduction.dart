import 'package:hive/hive.dart';

part 'reproduction.g.dart';

@HiveType(typeId: 5)
class Reproduction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String animalId;

  @HiveField(2)
  final DateTime dateEvenement;

  @HiveField(3)
  final String typeEvenement; // ex: "Saillie", "Insémination", "Diagnostic gestation", "Mise bas", "Avortement"

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime? datePrevueMiseBas;

  @HiveField(6)
  final String? partenaireId; // Mâle associé si saillie naturelle

  @HiveField(7)
  final bool succes;

  Reproduction({
    required this.id,
    required this.animalId,
    required this.dateEvenement,
    required this.typeEvenement,
    this.notes,
    this.datePrevueMiseBas,
    this.partenaireId,
    this.succes = true,
  });
}
