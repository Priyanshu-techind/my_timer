library my_timer;

// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'my_timer_controller/my_timer_controller.dart';

class MyTimer extends StatefulWidget {
  Duration tickInSecond;
  bool isIncrementing;
  int startTimerInSeconds;
  int endTimerInSeconds;
  MyTimerController? controller;
  Widget? child;
  TextStyle? style;

  MyTimer(
      {this.tickInSecond = const Duration(seconds: 1),
        this.isIncrementing = true,
        this.startTimerInSeconds = 0,
        this.endTimerInSeconds = 120,
        this.controller,
        this.child,
        this.style,
        super.key,
      });

  @override
  State<MyTimer> createState() => _MyTimerState();
}

class _MyTimerState extends State<MyTimer> {
  Timer? timer;
  late int remainingTimeInSeconds;
  MyTimerController? get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    remainingTimeInSeconds = widget.isIncrementing ? widget.startTimerInSeconds : widget.endTimerInSeconds;
    startTimer();

    // Set up the controller methods if a controller is provided
    if (controller != null) {
      controller!.start = startTimer;
      controller!.stop = stopTimer;
      controller!.getTimer = () {
        return Duration(seconds: remainingTimeInSeconds);
      };
    }
  }

  void startTimer() {
    // Stop any previous timers before starting a new one
    stopTimer();

    timer = Timer.periodic(widget.tickInSecond, (Timer t) {
      setState(() {
        if (widget.isIncrementing) {
          remainingTimeInSeconds++;
        } else {
          remainingTimeInSeconds--;
        }
      });

      // Trigger controller's callback if it exists
      if (controller != null && controller!.onTick != null) {
        controller!.onTick!(Duration(seconds: remainingTimeInSeconds));
      }

      // Check if timer completes
      if (_isTimeComplete()) {
        stopTimer();
        if (controller != null && controller!.onComplete != null) {
          controller!.onComplete!();
        }
      }
    });
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  bool _isTimeComplete() {
    return widget.isIncrementing
        ? remainingTimeInSeconds >= widget.endTimerInSeconds
        : remainingTimeInSeconds <= widget.startTimerInSeconds;
  }

  String getStringValue(int value) {
    return value <= 9 ? "0$value" : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    int hours = remainingTimeInSeconds ~/ 3600;
    int minutes = (remainingTimeInSeconds % 3600) ~/ 60;
    int seconds = remainingTimeInSeconds % 60;

    String timeText = "${hours > 0 ? "${getStringValue(hours)}:" : ""}${getStringValue(minutes)}:${getStringValue(seconds)}";

    return widget.child ??
        Text(
          timeText,
          style: widget.style ?? const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        );
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}

