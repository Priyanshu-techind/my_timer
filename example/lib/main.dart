import 'package:flutter/material.dart';
import 'package:my_timer/my_timer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'my_timer demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('my_timer demo'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Countdown'),
              Tab(text: 'Stopwatch'),
              Tab(text: 'Custom builder'),
              Tab(text: 'Formats'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CountdownDemo(),
            _StopwatchDemo(),
            _BuilderDemo(),
            _FormatsDemo(),
          ],
        ),
      ),
    );
  }
}

/// Pause / resume / reset / seek demo.
class _CountdownDemo extends StatefulWidget {
  const _CountdownDemo();

  @override
  State<_CountdownDemo> createState() => _CountdownDemoState();
}

class _CountdownDemoState extends State<_CountdownDemo> {
  final controller = MyTimerController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyTimer(
            controller: controller,
            duration: const Duration(seconds: 30),
            direction: TimerDirection.countDown,
            format: TimerFormat.minutesSeconds,
            autoStart: false,
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            onComplete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Countdown complete!')),
              );
            },
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(onPressed: controller.start, child: const Text('Start')),
              FilledButton.tonal(onPressed: controller.pause, child: const Text('Pause')),
              FilledButton.tonal(onPressed: controller.resume, child: const Text('Resume')),
              OutlinedButton(onPressed: controller.reset, child: const Text('Reset')),
              TextButton(
                onPressed: () => controller.add(const Duration(seconds: 10)),
                child: const Text('+10s'),
              ),
              TextButton(
                onPressed: () => controller.subtract(const Duration(seconds: 10)),
                child: const Text('-10s'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Count-up stopwatch with milliseconds precision.
class _StopwatchDemo extends StatefulWidget {
  const _StopwatchDemo();

  @override
  State<_StopwatchDemo> createState() => _StopwatchDemoState();
}

class _StopwatchDemoState extends State<_StopwatchDemo> {
  final controller = MyTimerController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyTimer(
            controller: controller,
            duration: const Duration(hours: 1),
            direction: TimerDirection.countUp,
            tickInterval: const Duration(milliseconds: 33),
            format: TimerFormat.minutesSecondsMillis,
            autoStart: false,
            style: const TextStyle(fontSize: 48, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            children: [
              FilledButton(onPressed: controller.start, child: const Text('Start')),
              FilledButton.tonal(onPressed: controller.pause, child: const Text('Pause')),
              OutlinedButton(onPressed: controller.reset, child: const Text('Reset')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom builder showing both elapsed (progress bar) and remaining (text).
class _BuilderDemo extends StatelessWidget {
  const _BuilderDemo();

  @override
  Widget build(BuildContext context) {
    const total = Duration(seconds: 20);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: MyTimer(
          duration: total,
          direction: TimerDirection.countDown,
          tickInterval: const Duration(milliseconds: 50),
          builder: (context, remaining, elapsed) {
            final progress = elapsed.inMilliseconds / total.inMilliseconds;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${remaining.inSeconds}s',
                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 240,
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Show every built-in format preset side by side.
class _FormatsDemo extends StatelessWidget {
  const _FormatsDemo();

  @override
  Widget build(BuildContext context) {
    const presets = TimerFormat.values;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        for (final preset in presets) ...[
          Text(preset.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          MyTimer(
            duration: const Duration(hours: 1, minutes: 30, seconds: 45),
            direction: TimerDirection.countUp,
            format: preset,
            tickInterval: const Duration(milliseconds: 100),
            style: const TextStyle(fontSize: 28, fontFamily: 'monospace'),
          ),
          const Divider(height: 32),
        ],
      ],
    );
  }
}
