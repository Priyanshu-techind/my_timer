import 'package:flutter/foundation.dart';
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
      home: const MyHomePage(title: 'My Timer Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MyTimerController _timerController; // Controller to manage the timer
  bool isTimerRunning = false; // Track the timer state
  int elapsedTimeInSeconds = 0; // Track elapsed time
  int timerDuration = 10; // Default timer duration
  String? errorMessage; // Variable for error messages

  @override
  void initState() {
    super.initState();
    // Initialize the timer controller with callbacks for ticks and completion
    _timerController = MyTimerController(
      onTick: (remainingDuration) {
        setState(() {
          elapsedTimeInSeconds = timerDuration - remainingDuration.inSeconds; // Calculate elapsed time
        });
        if (kDebugMode) {
          print("Time left: ${remainingDuration.inSeconds} seconds");
        }
      },
      onComplete: () {
        setState(() {
          isTimerRunning = false; // Update timer state on completion
        });
        if (kDebugMode) {
          print("Timer completed!");
        }
      },
    );
  }

  // Start the timer and update the running state
  void startTimer() {
    _timerController.start();
    setState(() {
      isTimerRunning = true; // Update timer state to running
    });
  }

  // Stop the timer and update the running state
  void stopTimer() {
    _timerController.stop();
    setState(() {
      isTimerRunning = false; // Update timer state to stopped
    });
  }

  // Reset the timer and elapsed time
  void resetTimer() {
    stopTimer(); // Stop the timer if running
    setState(() {
      elapsedTimeInSeconds = 0; // Reset elapsed time
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Input field for user to set the timer duration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Set Timer Duration (seconds)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Validate and update timer duration
                  final int? duration = int.tryParse(value);
                  if (duration != null && duration > 0) {
                    setState(() {
                      timerDuration = duration;
                      errorMessage = null; // Clear error message on valid input
                    });
                  } else {
                    setState(() {
                      errorMessage = 'Please enter a positive number'; // Set error message
                    });
                  }
                },
              ),
            ),
            if (errorMessage != null) // Display error message if exists
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            // Display the timer, setting the duration for the timer
            MyTimer(
              startTimerInSeconds: 0,
              endTimerInSeconds: timerDuration, // Timer will count down from the user-defined duration
              controller: _timerController,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Display elapsed time to the user
            Text(
              'Elapsed Time: $elapsedTimeInSeconds seconds',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Button to start the timer
            ElevatedButton(
              onPressed: isTimerRunning ? null : startTimer,
              // Disable if timer is running
              style: ElevatedButton.styleFrom(
                backgroundColor: isTimerRunning ? Colors.grey : Colors.blue, // Change color based on state
              ),
              child: const Text('Start Timer'),
            ),
            const SizedBox(height: 10),
            // Button to stop the timer
            ElevatedButton(
              onPressed: isTimerRunning ? stopTimer : null,
              // Disable if timer is stopped
              style: ElevatedButton.styleFrom(
                backgroundColor: isTimerRunning ? Colors.red : Colors.grey, // Change color based on state
              ),
              child: const Text('Stop Timer'),
            ),
            const SizedBox(height: 10),
            // Button to reset the timer
            ElevatedButton(
              onPressed: resetTimer, // Always enabled to reset
              child: const Text('Reset Timer'),
            ),
          ],
        ),
      ),
    );
  }
}
