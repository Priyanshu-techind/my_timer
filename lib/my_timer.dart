import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/my_timer_controller.dart';
import 'controller/my_timer_provider.dart';

class MyTimer extends StatelessWidget {
  final Duration tickInSecond;
  final bool isIncrementing;
  final int startTimerInSeconds;
  final int endTimerInSeconds;
  final MyTimerController? controller;
  final Widget Function({required BuildContext context, required int remainingTime})? builder;
  final Widget? child;
  final TextStyle? style;

  const MyTimer({
    this.tickInSecond = const Duration(seconds: 1),
    this.isIncrementing = true,
    this.startTimerInSeconds = 0,
    this.endTimerInSeconds = 120,
    this.controller,
    this.builder,
    this.child,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyTimerProvider(
        tickInSecond: tickInSecond,
        isIncrementing: isIncrementing,
        startTimerInSeconds: startTimerInSeconds,
        endTimerInSeconds: endTimerInSeconds,
        controller: controller,
      ),
      child: Consumer<MyTimerProvider>(
        builder: (ctx, provider, _) {
          int remainingTimeInSeconds = provider.remainingTimeInSeconds;

          if (builder != null) {
            /// return custom widget
            return builder!(context: ctx, remainingTime: remainingTimeInSeconds);
          }

          // Display default text or child widget
          int hours = remainingTimeInSeconds ~/ 3600;
          int minutes = (remainingTimeInSeconds % 3600) ~/ 60;
          int seconds = remainingTimeInSeconds % 60;

          String timeText = "${_getStringValue(hours)}:${_getStringValue(minutes)}:${_getStringValue(seconds)}";

          return child ??
              Text(
                timeText,
                style: style ?? const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
              );
        },
      ),
    );
  }

  String _getStringValue(int value) {
    return value <= 9 ? "0$value" : value.toString();
  }
}
