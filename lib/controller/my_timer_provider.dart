import 'dart:async';
import 'package:flutter/material.dart';
import 'my_timer_controller.dart';

class MyTimerProvider extends ChangeNotifier {
  final Duration tickInSecond;
  final bool isIncrementing;
  final int startTimerInSeconds;
  final int endTimerInSeconds;
  final MyTimerController? controller;

  Timer? timer;
  late int remainingTimeInSeconds;
  int _elapsedTimeInSeconds = 0;  // Added elapsed time tracker

  MyTimerProvider({
    required this.tickInSecond,
    required this.isIncrementing,
    required this.startTimerInSeconds,
    required this.endTimerInSeconds,
    this.controller,
  }) {
    remainingTimeInSeconds = isIncrementing ? startTimerInSeconds : endTimerInSeconds;
    _elapsedTimeInSeconds = 0;  // Initialize elapsed time to 0
    _initializeController();
    startTimer();
  }

  /// Getter for elapsed time
  int get elapsedTimeInSeconds => _elapsedTimeInSeconds;

  void _initializeController() {
    if (controller != null) {
      controller!.start = startTimer;
      controller!.stop = stopTimer;
      controller!.getTimer = () => Duration(seconds: remainingTimeInSeconds);
    }
  }

  void startTimer() {
    stopTimer();
    _elapsedTimeInSeconds = 0;  // Reset elapsed time when starting the timer

    timer = Timer.periodic(tickInSecond, (t) {
      if (isIncrementing) {
        remainingTimeInSeconds++;
        _elapsedTimeInSeconds++;  // Increment elapsed time
      } else {
        remainingTimeInSeconds--;
        _elapsedTimeInSeconds = endTimerInSeconds - remainingTimeInSeconds;  // Track elapsed time in decrement mode
      }
      notifyListeners();

      // Trigger controller's onTick callback
      controller?.onTick?.call(Duration(seconds: remainingTimeInSeconds));

      // Check if the timer completes
      if (_isTimeComplete()) {
        stopTimer();
        controller?.onComplete?.call();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  bool _isTimeComplete() {
    return isIncrementing
        ? remainingTimeInSeconds >= endTimerInSeconds
        : remainingTimeInSeconds <= startTimerInSeconds;
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}
