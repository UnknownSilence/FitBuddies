import '../models/workout.dart';

abstract class WorkoutService {
  Future<List<Workout>> getUserWorkouts(String userId);
  Future<Workout> addWorkout(Workout workout);
  Future<bool> deleteWorkout(String workoutId);
}

class MockWorkoutService implements WorkoutService {
  final List<Workout> _workouts = [
    Workout(
      id: 'w1',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      workoutType: 'Strength',
      durationMinutes: 60,
      exercises: [
        Exercise(name: 'Bench Press', sets: 3, reps: 10, weight: 135),
        Exercise(name: 'Squat', sets: 3, reps: 8, weight: 185),
        Exercise(name: 'Pull-ups', sets: 3, reps: 8),
      ],
    ),
    Workout(
      id: 'w2',
      userId: 'user1',
      date: DateTime.now().subtract(const Duration(days: 3)),
      workoutType: 'Cardio',
      durationMinutes: 45,
      exercises: [Exercise(name: 'Running', sets: 1, reps: 1)],
      notes: 'Ran 5K at moderate pace',
    ),
    // Partner's workouts
    Workout(
      id: 'w3',
      userId: 'user2',
      date: DateTime.now().subtract(const Duration(days: 1)),
      workoutType: 'CrossFit',
      durationMinutes: 50,
      exercises: [
        Exercise(name: 'Burpees', sets: 3, reps: 15),
        Exercise(name: 'Box Jumps', sets: 3, reps: 12),
        Exercise(name: 'Kettlebell Swings', sets: 3, reps: 20, weight: 35),
      ],
    ),
  ];

  @override
  Future<List<Workout>> getUserWorkouts(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _workouts.where((workout) => workout.userId == userId).toList();
  }

  @override
  Future<Workout> addWorkout(Workout workout) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final newWorkout = Workout(
      id: 'w${_workouts.length + 1}',
      userId: workout.userId,
      date: workout.date,
      workoutType: workout.workoutType,
      durationMinutes: workout.durationMinutes,
      exercises: workout.exercises,
      notes: workout.notes,
    );

    _workouts.add(newWorkout);
    return newWorkout;
  }

  @override
  Future<bool> deleteWorkout(String workoutId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final initialLength = _workouts.length;
    _workouts.removeWhere((workout) => workout.id == workoutId);
    return _workouts.length < initialLength;
  }
}
