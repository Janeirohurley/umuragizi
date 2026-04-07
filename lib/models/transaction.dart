import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 6)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // "Dépense" ou "Revenu"

  @HiveField(2)
  final double montant;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String categorie; // "Alimentation", "Frais Vétérinaires", "Vente", "Autre"

  @HiveField(5)
  final String? animalId; // Si la transaction est liée à un animal spécifique

  @HiveField(6)
  final String? description;

  Transaction({
    required this.id,
    required this.type,
    required this.montant,
    required this.date,
    required this.categorie,
    this.animalId,
    this.description,
  });
}
