import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/metric_service.dart';
import '../models/metric.dart';
import 'match_screen.dart';
import 'workout_screen.dart';
import 'metrics_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  // Simple constructor with optional key parameter
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = MockUserService();
  final MetricService _metricService = MockMetricService();
  late Future<User> _userFuture;
  late Future<List<Metric>> _gymVisitsFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getCurrentUser();
    _gymVisitsFuture = _fetchGymVisits();
  }

  Future<List<Metric>> _fetchGymVisits() async {
    final user = await _userFuture;
    return _metricService.getUserMetrics(user.id, type: MetricType.gymVisit);
  }

  int _calculateCurrentStreak(List<Metric> gymVisits) {
    if (gymVisits.isEmpty) return 0;

    // Sort by date (latest first)
    gymVisits.sort((a, b) => b.date.compareTo(a.date));

    int streak = 1;
    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    // Check if most recent visit was today or yesterday
    if (gymVisits[0].date.day != today.day &&
        gymVisits[0].date.day != yesterday.day) {
      return 0;
    }

    // Count streak
    for (int i = 0; i < gymVisits.length - 1; i++) {
      final current = gymVisits[i].date;
      final previous = gymVisits[i + 1].date;

      // If visits are on consecutive days
      if (current.difference(previous).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on bottom nav selection
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MetricsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitBuddies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to profile screen
              // To be implemented
            },
          ),
        ],
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user.profileImageUrl),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user.name}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'Fitness Level: ${user.fitnessLevel.toUpperCase()}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Streak Card
                  FutureBuilder<List<Metric>>(
                    future: _gymVisitsFuture,
                    builder: (context, snapshot) {
                      int streak = 0;
                      if (snapshot.hasData) {
                        streak = _calculateCurrentStreak(snapshot.data!);
                      }

                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                size: 40,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Current Gym Streak'),
                                  Text(
                                    '$streak days',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Action Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Find Partner',
                          Icons.people,
                          Colors.blue,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MatchScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Log Workout',
                          Icons.fitness_center,
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Track Metrics',
                          Icons.trending_up,
                          Colors.purple,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MetricsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Chat',
                          Icons.chat,
                          Colors.orange,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Metrics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
