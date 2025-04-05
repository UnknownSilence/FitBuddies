class Metric {
  final String id;
  final String userId;
  final DateTime date;
  final MetricType type;
  final double value;
  final String? notes;

  Metric({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.value,
    this.notes,
  });

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      type: MetricType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      value: json['value'].toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'value': value,
      'notes': notes,
    };
  }
}

enum MetricType {
  weight,
  bodyFatPercentage,
  chestCircumference,
  waistCircumference,
  armCircumference,
  legCircumference,
  gymVisit,
  caloriesBurned,
}
