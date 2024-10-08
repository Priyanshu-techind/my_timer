import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_timer/my_timer.dart';
import 'package:my_timer/src/my_timer_controller/my_timer_controller.dart';

void main() {
  late MyTimerController controller;

  setUp(() {
    // Initialize the controller before each test
    controller = MyTimerController();
  });

  testWidgets('MyTimer increments time correctly', (WidgetTester tester) async {
    // Create the MyTimer widget with incrementing mode
    await tester.pumpWidget(
      MaterialApp(
        home: MyTimer(
          isIncrementing: true,
          startTimerInSeconds: 0,
          endTimerInSeconds: 5,
          tickInSecond: const Duration(seconds: 1),
          controller: controller,
        ),
      ),
    );

    // Initially, the timer should start at 0 seconds
    expect(find.text('00:00'), findsOneWidget);

    // Simulate the passage of time for 3 ticks (3 seconds)
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:03'), findsOneWidget);
  });

  testWidgets('MyTimer decrements time correctly', (WidgetTester tester) async {
    // Create the MyTimer widget with decrementing mode
    await tester.pumpWidget(
      MaterialApp(
        home: MyTimer(
          isIncrementing: false,
          startTimerInSeconds: 0,
          endTimerInSeconds: 5,
          tickInSecond: const Duration(seconds: 1),
          controller: controller,
        ),
      ),
    );

    // Initially, the timer should start at 5 seconds
    expect(find.text('00:05'), findsOneWidget);

    // Simulate the passage of time for 3 ticks (3 seconds)
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:02'), findsOneWidget);
  });

  testWidgets('MyTimer stops correctly when time completes', (WidgetTester tester) async {
    bool isCompleted = false;

    // Assign the controller callback for completion
    controller.onComplete = () {
      isCompleted = true;
    };

    // Create the MyTimer widget with a small range of time
    await tester.pumpWidget(
      MaterialApp(
        home: MyTimer(
          isIncrementing: true,
          startTimerInSeconds: 0,
          endTimerInSeconds: 2,
          tickInSecond: const Duration(seconds: 1),
          controller: controller,
        ),
      ),
    );

    // Simulate the passage of time for 3 ticks (3 seconds)
    await tester.pump(const Duration(seconds: 3));

    // Verify if the timer completed and stopped
    expect(isCompleted, isTrue);
    expect(find.text('00:02'), findsOneWidget); // Timer should stop at 2 seconds
  });

  testWidgets('MyTimer controller stop method works correctly', (WidgetTester tester) async {
    // Create the MyTimer widget
    await tester.pumpWidget(
      MaterialApp(
        home: MyTimer(
          isIncrementing: true,
          startTimerInSeconds: 0,
          endTimerInSeconds: 5,
          tickInSecond: const Duration(seconds: 1),
          controller: controller,
        ),
      ),
    );

    // Initially, the timer should start at 0 seconds
    expect(find.text('00:00'), findsOneWidget);

    // Simulate the passage of time for 2 ticks (2 seconds)
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:02'), findsOneWidget);

    // Stop the timer via the controller
    controller.stop();

    // Simulate the passage of more time, the timer should not increment further
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:02'), findsOneWidget); // Timer remains at 2 seconds
  });
}
