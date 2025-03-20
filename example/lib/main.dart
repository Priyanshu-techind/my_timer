import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_timer/my_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Timer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _timer; // Timer instance for handling countdown logic
  int elapsedTimeInSeconds = 0; // Tracks elapsed time in seconds
  int timerDuration = 10; // Default timer duration
  String? errorMessage; // Stores error messages for invalid input
  final TextEditingController _durationController =
      TextEditingController(); // Controller for user input

  @override
  void initState() {
    super.initState();
    _durationController.text =
        timerDuration.toString(); // Initialize text field with default duration
  }

  /// Starts the timer
  void startTimer() {
    final int? duration = int.tryParse(
        _durationController.text); // Convert user input to an integer
    if (duration != null && duration > 0) {
      setState(() {
        timerDuration = duration;
        elapsedTimeInSeconds = 0; // Reset elapsed time
        errorMessage = null; // Clear error message
      });

      _timer?.cancel(); // Cancel any existing timer before starting a new one

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (elapsedTimeInSeconds < timerDuration) {
          setState(() {
            elapsedTimeInSeconds++; // Increment elapsed time every second
          });
        } else {
          timer.cancel(); // Stop the timer when the duration is reached
          debugPrint("Timer completed!");
        }
      });
    } else {
      setState(() {
        errorMessage =
            'Please enter a valid duration (positive number)'; // Show error if input is invalid
      });
    }
  }

  /// Stops the timer
  void stopTimer() {
    _timer?.cancel(); // Cancel the timer to stop counting
  }

  /// Resets the timer
  void resetTimer() {
    stopTimer(); // Stop the timer before resetting
    final int? duration = int.tryParse(_durationController.text);
    if (duration != null && duration > 0) {
      setState(() {
        timerDuration = duration;
        elapsedTimeInSeconds = 0; // Reset elapsed time
        errorMessage = null; // Clear error message
      });
    } else {
      setState(() {
        errorMessage =
            'Please enter a valid duration'; // Show error if input is invalid
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    _durationController.dispose(); // Dispose the text controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Simple Timer'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input field for setting timer duration
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Set Timer Duration (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Ensures only numeric input
            ),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(
                    color: Colors.red), // Display error message in red
              ),

            const SizedBox(height: 20),

            // Display elapsed time
            Text(
              'Elapsed Time: $elapsedTimeInSeconds sec',
              style: const TextStyle(fontSize: 20),
            ),

            // Custom Timer Widget (MyTimer) from the my_timer package
            MyTimer(
              isIncrementing: false,
              // Countdown mode
              startTimerInSeconds: 0,
              // End at 0 seconds
              endTimerInSeconds: 100,
              // Start from 100 seconds because of isIncrementing is false
              builder: ({required context, required remainingTime}) {
                return Text(
                  'Remaining Time in Seconds $remainingTime',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                );
              },
            ),

            const SizedBox(height: 20),

            // Buttons for Timer Control
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 20,
              children: [
                ElevatedButton(
                  onPressed: startTimer,
                  child: const Text('Start Timer'), // Starts the timer
                ),
                ElevatedButton(
                  onPressed: stopTimer,
                  child: const Text('Stop Timer'), // Stops the timer
                ),
                ElevatedButton(
                  onPressed: resetTimer,
                  child: const Text('Reset Timer'), // Resets the timer
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
