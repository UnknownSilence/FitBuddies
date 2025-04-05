import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class AddWorkoutScreen extends StatefulWidget {
  final String userId;
  final WorkoutService? workoutService;

  const AddWorkoutScreen({Key? key, required this.userId, this.workoutService})
    : super(key: key);

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late WorkoutService _workoutService;
  final List<Exercise> _exercises = [];

  late TextEditingController _workoutTypeController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _workoutService = widget.workoutService ?? MockWorkoutService();
    _workoutTypeController = TextEditingController();
    _durationController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _addExercise() {
    final nameController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Exercise',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (lbs, optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      setsController.text.isEmpty ||
                      repsController.text.isEmpty) {
                    return;
                  }

                  setState(() {
                    _exercises.add(
                      Exercise(
                        name: nameController.text,
                        sets: int.parse(setsController.text),
                        reps: int.parse(repsController.text),
                        weight:
                            weightController.text.isNotEmpty
                                ? double.parse(weightController.text)
                                : null,
                      ),
                    );
                  });

                  Navigator.pop(context);
                },
                child: const Text('Add Exercise'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveWorkout() async {
    if (_formKey.currentState!.validate() && _exercises.isNotEmpty) {
      final workout = Workout(
        id: '', // Will be assigned by service
        userId: widget.userId,
        date: _selectedDate,
        workoutType: _workoutTypeController.text,
        durationMinutes: int.parse(_durationController.text),
        exercises: _exercises,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await _workoutService.addWorkout(workout);

      if (!mounted) return;

      Navigator.pop(context, true);
    } else if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _workoutTypeController,
              decoration: const InputDecoration(
                labelText: 'Workout Type',
                hintText: 'e.g., Strength, Cardio, Yoga',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a workout type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a duration';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercises',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: _addExercise,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_exercises.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No exercises added yet'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          return ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(
                              '${exercise.sets} sets x ${exercise.reps} reps ${exercise.weight != null ? '@ ${exercise.weight} lbs' : ''}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _exercises.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _workoutTypeController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
