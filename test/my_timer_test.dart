import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_timer/my_timer.dart';

void main() {
  group('MyTimer count-up', () {
    testWidgets('counts up from 00:00', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyTimer(
            duration: Duration(seconds: 5),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:03'), findsOneWidget);
    });
  });

  group('MyTimer count-down', () {
    testWidgets('counts down from duration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyTimer(
            duration: Duration(seconds: 5),
            direction: TimerDirection.countDown,
            format: TimerFormat.minutesSeconds,
          ),
        ),
      );

      expect(find.text('00:05'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:02'), findsOneWidget);
    });
  });

  group('MyTimer completion', () {
    testWidgets('fires onComplete and stops at boundary', (tester) async {
      var completedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 2),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
            onComplete: () => completedCount++,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 3));

      expect(completedCount, 1);
      expect(find.text('00:02'), findsOneWidget);

      // Should not fire again on further pumps.
      await tester.pump(const Duration(seconds: 5));
      expect(completedCount, 1);
    });
  });

  group('MyTimerController', () {
    testWidgets('pause preserves elapsed time', (tester) async {
      final controller = MyTimerController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 10),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
            controller: controller,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:02'), findsOneWidget);

      controller.pause();
      await tester.pump(const Duration(seconds: 3));
      // While paused, the display should stay at 00:02.
      expect(find.text('00:02'), findsOneWidget);
      expect(controller.isPaused, isTrue);
      expect(controller.isRunning, isFalse);
    });

    testWidgets('resume continues from paused value', (tester) async {
      final controller = MyTimerController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 10),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
            controller: controller,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      controller.pause();
      await tester.pump(const Duration(seconds: 5));
      controller.resume();
      await tester.pump(const Duration(seconds: 1));

      // 2s before pause + 1s after resume = 3s.
      expect(find.text('00:03'), findsOneWidget);
    });

    testWidgets('reset zeroes elapsed time', (tester) async {
      final controller = MyTimerController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 10),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
            controller: controller,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 3));
      controller.reset();
      await tester.pump();
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('seek jumps to position', (tester) async {
      final controller = MyTimerController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 60),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
            controller: controller,
            autoStart: false,
          ),
        ),
      );

      controller.seek(const Duration(seconds: 30));
      await tester.pump();
      expect(find.text('00:30'), findsOneWidget);
    });

    testWidgets('add and subtract adjust elapsed time', (tester) async {
      final controller = MyTimerController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 60),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
            controller: controller,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 5));
      controller.add(const Duration(seconds: 10));
      await tester.pump();
      expect(find.text('00:15'), findsOneWidget);

      controller.subtract(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text('00:10'), findsOneWidget);
    });

    testWidgets('getTimer returns display value (legacy API)', (tester) async {
      final controller = MyTimerController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 10),
            direction: TimerDirection.countDown,
            controller: controller,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 3));
      // Count-down: getTimer should return remaining.
      expect(controller.getTimer(), const Duration(seconds: 7));
    });

    testWidgets('stop (legacy alias for pause) works', (tester) async {
      final controller = MyTimerController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 10),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
            controller: controller,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      controller.stop();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:02'), findsOneWidget);
    });

    testWidgets('method calls are safe before attachment', (tester) async {
      final controller = MyTimerController();
      // None of these should throw despite no widget being mounted.
      controller.start();
      controller.pause();
      controller.resume();
      controller.reset();
      controller.seek(const Duration(seconds: 5));
      controller.add(const Duration(seconds: 5));
      controller.subtract(const Duration(seconds: 5));
      expect(controller.isAttached, isFalse);
      expect(controller.isRunning, isFalse);
      expect(controller.elapsed, Duration.zero);
      expect(controller.remaining, Duration.zero);
      expect(controller.getTimer(), Duration.zero);
    });
  });

  group('autoStart', () {
    testWidgets('false keeps timer paused until start()', (tester) async {
      final controller = MyTimerController();

      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 10),
            direction: TimerDirection.countUp,
            format: TimerFormat.minutesSeconds,
            autoStart: false,
            controller: controller,
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 5));
      expect(find.text('00:00'), findsOneWidget);
      expect(controller.isRunning, isFalse);

      controller.start();
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:02'), findsOneWidget);
    });
  });

  group('format presets', () {
    test('minutesSeconds', () {
      expect(formatDuration(const Duration(seconds: 93), TimerFormat.minutesSeconds), '01:33');
    });

    test('hoursMinutesSeconds', () {
      expect(formatDuration(const Duration(seconds: 3725), TimerFormat.hoursMinutesSeconds), '01:02:05');
    });

    test('minutesSecondsMillis', () {
      expect(
        formatDuration(const Duration(milliseconds: 93250), TimerFormat.minutesSecondsMillis),
        '01:33.250',
      );
    });

    test('auto picks mm:ss under an hour', () {
      expect(formatDuration(const Duration(seconds: 45), TimerFormat.auto), '00:45');
    });

    test('auto picks hh:mm:ss past an hour', () {
      expect(formatDuration(const Duration(hours: 2, minutes: 3, seconds: 4), TimerFormat.auto), '02:03:04');
    });

    test('auto picks dd:hh:mm:ss past a day', () {
      expect(
        formatDuration(const Duration(days: 1, hours: 2, minutes: 3, seconds: 4), TimerFormat.auto),
        '01:02:03:04',
      );
    });
  });

  group('legacy 1.x API', () {
    testWidgets('isIncrementing + startTimerInSeconds + endTimerInSeconds still work', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          // ignore: deprecated_member_use_from_same_package
          home: MyTimer(
            isIncrementing: false,
            startTimerInSeconds: 0,
            endTimerInSeconds: 5,
            format: TimerFormat.minutesSeconds,
          ),
        ),
      );

      expect(find.text('00:05'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:02'), findsOneWidget);
    });

    testWidgets('legacyBuilder receives int remainingTime', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MyTimer(
            duration: const Duration(seconds: 10),
            direction: TimerDirection.countDown,
            legacyBuilder: ({required context, required remainingTime}) {
              return Text('R=$remainingTime');
            },
          ),
        ),
      );

      expect(find.text('R=10'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('R=7'), findsOneWidget);
    });
  });
}
