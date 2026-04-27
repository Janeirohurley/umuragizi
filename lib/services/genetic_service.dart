import 'dart:math' as math;

import '../models/models.dart';
import 'database_service.dart';

class GeneticService {
  static const double defaultHeritability = 0.3;

  static double calculateEBV(
    Animal animal,
    List<Animal> population, {
    double heritability = defaultHeritability,
  }) {
    final peers = population
        .where((candidate) => candidate.espece == animal.espece)
        .toList();
    if (peers.isEmpty) {
      return 0;
    }

    final metricsCache = <String, _GeneticMetrics>{};
    _GeneticMetrics metricsFor(Animal candidate) {
      return metricsCache.putIfAbsent(
        candidate.id,
        () => _buildMetrics(candidate),
      );
    }

    final animalMetrics = metricsFor(animal);
    if (!animalMetrics.hasData) {
      return 0;
    }

    final peerMetrics = peers
        .map(metricsFor)
        .where((metrics) => metrics.hasData)
        .toList();
    if (peerMetrics.isEmpty) {
      return 0;
    }

    final traitEbvs = <double>[];

    if (animalMetrics.latestWeight != null) {
      final weights = peerMetrics
          .map((metrics) => metrics.latestWeight)
          .whereType<double>()
          .toList();
      final averageWeight = _mean(weights);
      if (averageWeight != null) {
        traitEbvs.add(
          (animalMetrics.latestWeight! - averageWeight) * heritability,
        );
      }
    }

    if (animalMetrics.averageDailyGain != null) {
      final gains = peerMetrics
          .map((metrics) => metrics.averageDailyGain)
          .whereType<double>()
          .toList();
      final averageGain = _mean(gains);
      if (averageGain != null) {
        traitEbvs.add(
          (animalMetrics.averageDailyGain! - averageGain) * heritability,
        );
      }
    }

    if (traitEbvs.isEmpty) {
      return 0;
    }

    return traitEbvs.reduce((sum, value) => sum + value) / traitEbvs.length;
  }

  static double calculateInbreedingCoefficient(
    Animal animal,
    List<Animal> population,
  ) {
    if (animal.mereId == null || animal.pereId == null) {
      return 0;
    }

    final animalMap = {
      for (final candidate in population) candidate.id: candidate,
    };
    final kinshipMemo = <String, double>{};
    final inbreedingMemo = <String, double>{};

    return _clampProbability(
      _kinship(
        animal.mereId,
        animal.pereId,
        animalMap,
        kinshipMemo,
        inbreedingMemo,
        <String>{},
      ),
    );
  }

  static Future<GeneticInfo> updateGeneticInfo(
    Animal animal, {
    List<Animal>? population,
    double heritability = defaultHeritability,
  }) async {
    final herd = population ?? DatabaseService.getTousLesAnimaux();
    final info = GeneticInfo(
      animalId: animal.id,
      ebv: calculateEBV(
        animal,
        herd,
        heritability: heritability,
      ),
      inbreedingCoefficient: calculateInbreedingCoefficient(animal, herd),
      lastCalculatedAt: DateTime.now(),
    );
    await DatabaseService.saveGeneticInfo(info);
    return info;
  }

  static GeneticMetrics metricsForAnimal(Animal animal) {
    final metrics = _buildMetrics(animal);
    return GeneticMetrics(
      latestWeight: metrics.latestWeight,
      averageDailyGain: metrics.averageDailyGain,
    );
  }

  static _GeneticMetrics _buildMetrics(Animal animal) {
    final croissances = DatabaseService.getCroissancesParAnimal(animal.id);
    if (croissances.isEmpty) {
      return const _GeneticMetrics();
    }

    final latestWeight = croissances.last.poids;
    double? averageDailyGain;
    if (croissances.length >= 2) {
      final first = croissances.first;
      final last = croissances.last;
      final days = last.date.difference(first.date).inDays;
      if (days > 0) {
        averageDailyGain = (last.poids - first.poids) / days;
      }
    }

    return _GeneticMetrics(
      latestWeight: latestWeight,
      averageDailyGain: averageDailyGain,
    );
  }

  static double? _mean(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((sum, value) => sum + value) / values.length;
  }

  static double _kinship(
    String? firstId,
    String? secondId,
    Map<String, Animal> animalMap,
    Map<String, double> kinshipMemo,
    Map<String, double> inbreedingMemo,
    Set<String> activeCalls,
  ) {
    if (firstId == null || secondId == null) {
      return 0;
    }

    final orderedIds = [firstId, secondId]..sort();
    final memoKey = orderedIds.join('|');
    final activeKey = 'kinship:$memoKey';

    if (kinshipMemo.containsKey(memoKey)) {
      return kinshipMemo[memoKey]!;
    }
    if (!activeCalls.add(activeKey)) {
      return 0;
    }

    double result;
    if (firstId == secondId) {
      result = 0.5 *
          (1 +
              _inbreedingForAnimal(
                firstId,
                animalMap,
                kinshipMemo,
                inbreedingMemo,
                activeCalls,
              ));
    } else {
      final firstAnimal = animalMap[firstId];
      final secondAnimal = animalMap[secondId];
      if (firstAnimal == null || secondAnimal == null) {
        result = 0;
      } else if (firstId.compareTo(secondId) <= 0) {
        result = 0.5 *
            (_kinship(
                  firstAnimal.pereId,
                  secondId,
                  animalMap,
                  kinshipMemo,
                  inbreedingMemo,
                  activeCalls,
                ) +
                _kinship(
                  firstAnimal.mereId,
                  secondId,
                  animalMap,
                  kinshipMemo,
                  inbreedingMemo,
                  activeCalls,
                ));
      } else {
        result = 0.5 *
            (_kinship(
                  secondAnimal.pereId,
                  firstId,
                  animalMap,
                  kinshipMemo,
                  inbreedingMemo,
                  activeCalls,
                ) +
                _kinship(
                  secondAnimal.mereId,
                  firstId,
                  animalMap,
                  kinshipMemo,
                  inbreedingMemo,
                  activeCalls,
                ));
      }
    }

    activeCalls.remove(activeKey);
    final safeResult = _clampProbability(result);
    kinshipMemo[memoKey] = safeResult;
    return safeResult;
  }

  static double _inbreedingForAnimal(
    String animalId,
    Map<String, Animal> animalMap,
    Map<String, double> kinshipMemo,
    Map<String, double> inbreedingMemo,
    Set<String> activeCalls,
  ) {
    if (inbreedingMemo.containsKey(animalId)) {
      return inbreedingMemo[animalId]!;
    }

    final animal = animalMap[animalId];
    if (animal == null || animal.mereId == null || animal.pereId == null) {
      return 0;
    }

    final activeKey = 'inbreeding:$animalId';
    if (!activeCalls.add(activeKey)) {
      return 0;
    }

    final result = _clampProbability(
      _kinship(
        animal.mereId,
        animal.pereId,
        animalMap,
        kinshipMemo,
        inbreedingMemo,
        activeCalls,
      ),
    );

    activeCalls.remove(activeKey);
    inbreedingMemo[animalId] = result;
    return result;
  }

  static double _clampProbability(double value) {
    return math.max(0, math.min(1, value));
  }
}

class GeneticMetrics {
  final double? latestWeight;
  final double? averageDailyGain;

  const GeneticMetrics({
    this.latestWeight,
    this.averageDailyGain,
  });

  bool get hasData => latestWeight != null || averageDailyGain != null;
}

class _GeneticMetrics extends GeneticMetrics {
  const _GeneticMetrics({
    super.latestWeight,
    super.averageDailyGain,
  });
}
