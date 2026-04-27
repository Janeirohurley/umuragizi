import 'package:hive/hive.dart';

part 'genetic_info.g.dart';

@HiveType(typeId: 9)
class GeneticInfo extends HiveObject {
  @HiveField(0)
  final String animalId;

  @HiveField(1)
  final double ebv;

  @HiveField(2)
  final double inbreedingCoefficient;

  @HiveField(3)
  final DateTime lastCalculatedAt;

  GeneticInfo({
    required this.animalId,
    required this.ebv,
    required this.inbreedingCoefficient,
    required this.lastCalculatedAt,
  });
}
