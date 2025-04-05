import 'package:flutter/material.dart';
import '../models/metric.dart';
import '../services/metric_service.dart';
import '../services/user_service.dart';
import 'add_metric_screen.dart';

class MetricsScreen extends StatefulWidget {
  final UserService? userService;
  final MetricService? metricService;

  const MetricsScreen({Key? key, this.userService, this.metricService})
    : super(key: key);

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  late UserService _userService;
  late MetricService _metricService;
  late Future<Map<String, List<Metric>>> _metricsFuture;
  MetricType _selectedMetricType = MetricType.weight;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? MockUserService();
    _metricService = widget.metricService ?? MockMetricService();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final user = await _userService.getCurrentUser();
    _userId = user.id;

    _metricsFuture = Future.wait([
      _metricService.getUserMetrics(user.id, type: MetricType.weight),
      _metricService.getUserMetrics(
        user.id,
        type: MetricType.bodyFatPercentage,
      ),
      _metricService.getUserMetrics(user.id, type: MetricType.gymVisit),
    ]).then((results) {
      return {
        'weight': results[0],
        'bodyFat': results[1],
        'gymVisits': results[2],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Metrics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<MetricType>(
              segments: const [
                ButtonSegment(
                  value: MetricType.weight,
                  label: Text('Weight'),
                  icon: Icon(Icons.monitor_weight),
                ),
                ButtonSegment(
                  value: MetricType.bodyFatPercentage,
                  label: Text('Body Fat'),
                  icon: Icon(Icons.percent),
                ),
                ButtonSegment(
                  value: MetricType.gymVisit,
                  label: Text('Gym Visits'),
                  icon: Icon(Icons.fitness_center),
                ),
              ],
              selected: {_selectedMetricType},
              onSelectionChanged: (Set<MetricType> newSelection) {
                setState(() {
                  _selectedMetricType = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, List<Metric>>>(
              future: _metricsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final metrics = snapshot.data!;
                List<Metric> currentMetrics;

                switch (_selectedMetricType) {
                  case MetricType.weight:
                    currentMetrics = metrics['weight']!;
                    break;
                  case MetricType.bodyFatPercentage:
                    currentMetrics = metrics['bodyFat']!;
                    break;
                  case MetricType.gymVisit:
                    currentMetrics = metrics['gymVisits']!;
                    break;
                  default:
                    currentMetrics = [];
                }

                if (currentMetrics.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${_getMetricName(_selectedMetricType)} data yet',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentMetrics.length,
                  itemBuilder: (context, index) {
                    final metric = currentMetrics[index];
                    return _buildMetricCard(metric);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddMetricScreen(
                    userId: _userId,
                    initialMetricType: _selectedMetricType,
                  ),
            ),
          );

          if (result == true) {
            _loadMetrics(); // Refresh the metrics
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getMetricName(MetricType type) {
    switch (type) {
      case MetricType.weight:
        return 'Weight';
      case MetricType.bodyFatPercentage:
        return 'Body Fat';
      case MetricType.gymVisit:
        return 'Gym Visit';
      default:
        return 'Metric';
    }
  }

  Widget _buildMetricCard(Metric metric) {
    String valueDisplay;
    IconData iconData;

    switch (metric.type) {
      case MetricType.weight:
        valueDisplay = '${metric.value} lbs';
        iconData = Icons.monitor_weight;
        break;
      case MetricType.bodyFatPercentage:
        valueDisplay = '${metric.value}%';
        iconData = Icons.percent;
        break;
      case MetricType.gymVisit:
        valueDisplay = metric.value == 1 ? 'Visit Logged' : '';
        iconData = Icons.fitness_center;
        break;
      default:
        valueDisplay = '${metric.value}';
        iconData = Icons.show_chart;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(iconData, size: 36),
        title: Text(valueDisplay),
        subtitle: Text(
          '${metric.date.day}/${metric.date.month}/${metric.date.year}',
        ),
        trailing: metric.notes != null ? const Icon(Icons.note) : null,
        onTap:
            metric.notes != null
                ? () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(_getMetricName(metric.type)),
                          content: Text(metric.notes!),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  );
                }
                : null,
      ),
    );
  }
}
