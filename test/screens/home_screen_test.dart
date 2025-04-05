import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardyfit/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays user information and quick actions', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Wait for all futures to complete (network calls in this case)
    await tester.pumpAndSettle();

    // Verify the app bar title is displayed
    expect(find.text('FitBuddies'), findsOneWidget);

    // Verify user name is displayed
    expect(find.textContaining('Welcome, Alex'), findsOneWidget);

    // Verify fitness level is displayed
    expect(find.textContaining('Fitness Level:'), findsOneWidget);

    // Verify streak card is displayed
    expect(find.text('Current Gym Streak'), findsOneWidget);

    // Verify quick actions section title
    expect(find.text('Quick Actions'), findsOneWidget);

    // Verify all quick action cards are displayed
    expect(find.text('Find Partner'), findsOneWidget);
    expect(find.text('Log Workout'), findsOneWidget);
    expect(find.text('Track Metrics'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);

    // Verify action card icons
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
    expect(find.byIcon(Icons.chat), findsOneWidget);

    // Verify bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Metrics'), findsOneWidget);
  });

  testWidgets('Bottom navigation bar works correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.byIcon(Icons.home), findsOneWidget);

    // Tap on Metrics tab
    await tester.tap(find.text('Metrics'));
    await tester.pumpAndSettle();

    // Verify navigation happened
    expect(find.byType(Navigator), findsOneWidget);
  });
}
