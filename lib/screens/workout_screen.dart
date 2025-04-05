import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../services/user_service.dart';
import 'add_workout_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final UserService userService;
  final WorkoutService workoutService;

  WorkoutScreen({
    Key? key,
    UserService? userService,
    WorkoutService? workoutService,
  }) : userService = userService ?? MockUserService(),
       workoutService = workoutService ?? MockWorkoutService(),
       super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late Future<List<Workout>> _workoutsFuture;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final user = await widget.userService.getCurrentUser();
    _userId = user.id;
    setState(() {
      _workoutsFuture = widget.workoutService.getUserWorkouts(user.id);
    });
  }

  Future<void> _deleteWorkout(String workoutId) async {
    final result = await widget.workoutService.deleteWorkout(workoutId);
    if (!mounted) return;

    if (result) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Workout deleted')));
      _loadWorkouts(); // Refresh the list
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete workout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: FutureBuilder<List<Workout>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final workouts = snapshot.data!;

          if (workouts.isEmpty) {
            return const Center(
              child: Text('No workouts yet. Log your first workout!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return Dismissible(
                key: Key(workout.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteWorkout(workout.id);
                },
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text(
                          "Are you sure you want to delete this workout?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: _buildWorkoutCard(workout),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddWorkoutScreen(
                    userId: _userId,
                    workoutService: widget.workoutService,
                  ),
            ),
          );

          if (result == true) {
            _loadWorkouts(); // Refresh the list
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  workout.workoutType,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${workout.date.day}/${workout.date.month}/${workout.date.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const Divider(),
            Text(
              'Duration: ${workout.durationMinutes} minutes',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text('Exercises:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            ...workout.exercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${exercise.name}: ${exercise.sets} sets x ${exercise.reps} reps ${exercise.weight != null ? '@ ${exercise.weight} lbs' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${workout.notes}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
