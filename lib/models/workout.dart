class Workout {
  final String id;
  final String userId;
  final DateTime date;
  final String workoutType;
  final int durationMinutes;
  final List<Exercise> exercises;
  final String? notes;

  Workout({
    required this.id,
    required this.userId,
    required this.date,
    required this.workoutType,
    required this.durationMinutes,
    required this.exercises,
    this.notes,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      workoutType: json['workoutType'],
      durationMinutes: json['durationMinutes'],
      exercises:
          (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'workoutType': workoutType,
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }
}

class Exercise {
  final String name;
  final int sets;
  final int reps;
  final double? weight; // Null if bodyweight exercise

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'sets': sets, 'reps': reps, 'weight': weight};
  }
}
