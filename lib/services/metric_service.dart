import '../models/metric.dart';

abstract class MetricService {
  Future<List<Metric>> getUserMetrics(String userId, {MetricType? type});
  Future<Metric> addMetric(Metric metric);
  Future<List<Metric>> getComparisonMetrics(
    String userId,
    String partnerId,
    MetricType type,
  );
}

class MockMetricService implements MetricService {
  final List<Metric> _metrics = [
    // User metrics
    Metric(
      id: 'm1',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: MetricType.weight,
      value: 185.5,
    ),
    Metric(
      id: 'm2',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: MetricType.weight,
      value: 183.2,
    ),
    Metric(
      id: 'm3',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: MetricType.bodyFatPercentage,
      value: 18.5,
    ),
    Metric(
      id: 'm4',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: MetricType.bodyFatPercentage,
      value: 18.0,
    ),
    Metric(
      id: 'm5',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: MetricType.gymVisit,
      value: 1.0,
    ),
    Metric(
      id: 'm6',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: MetricType.gymVisit,
      value: 1.0,
    ),
    Metric(
      id: 'm7',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: MetricType.gymVisit,
      value: 1.0,
    ),

    // Partner metrics
    Metric(
      id: 'm8',
      userId: 'user2',
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: MetricType.weight,
      value: 142.0,
    ),
    Metric(
      id: 'm9',
      userId: 'user2',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: MetricType.weight,
      value: 140.5,
    ),
    Metric(
      id: 'm10',
      userId: 'user2',
      date: DateTime.now().subtract(const Duration(days: 6)),
      type: MetricType.gymVisit,
      value: 1.0,
    ),
    Metric(
      id: 'm11',
      userId: 'user2',
      date: DateTime.now().subtract(const Duration(days: 4)),
      type: MetricType.gymVisit,
      value: 1.0,
    ),
    Metric(
      id: 'm12',
      userId: 'user2',
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: MetricType.gymVisit,
      value: 1.0,
    ),
    Metric(
      id: 'm13',
      userId: 'user2',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: MetricType.gymVisit,
      value: 1.0,
    ),
  ];

  @override
  Future<List<Metric>> getUserMetrics(String userId, {MetricType? type}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var metrics = _metrics.where((metric) => metric.userId == userId);

    if (type != null) {
      metrics = metrics.where((metric) => metric.type == type);
    }

    return metrics.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Metric> addMetric(Metric metric) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final newMetric = Metric(
      id: 'm${_metrics.length + 1}',
      userId: metric.userId,
      date: metric.date,
      type: metric.type,
      value: metric.value,
      notes: metric.notes,
    );

    _metrics.add(newMetric);
    return newMetric;
  }

  @override
  Future<List<Metric>> getComparisonMetrics(
    String userId,
    String partnerId,
    MetricType type,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final userMetrics =
        _metrics
            .where((metric) => metric.userId == userId && metric.type == type)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final partnerMetrics =
        _metrics
            .where(
              (metric) => metric.userId == partnerId && metric.type == type,
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return [...userMetrics, ...partnerMetrics];
  }
}
