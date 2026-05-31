import 'package:flutter/material.dart';

import 'controller/my_timer_controller.dart';
import 'src/my_timer_engine.dart';
import 'src/timer_direction.dart';
import 'src/timer_format.dart';

export 'controller/my_timer_controller.dart';
export 'src/timer_direction.dart';
export 'src/timer_format.dart';

/// Signature for the builder used to render a [MyTimer] with full access
/// to both elapsed and remaining time as [Duration]s.
typedef MyTimerWidgetBuilder = Widget Function(
  BuildContext context,
  Duration remaining,
  Duration elapsed,
);

/// Signature for the legacy 1.x builder (int seconds, named arguments).
/// Use [MyTimerWidgetBuilder] in new code.
typedef MyTimerLegacyBuilder = Widget Function({
  required BuildContext context,
  required int remainingTime,
});

/// A drift-free, drop-in timer widget.
///
/// Supports count-up and count-down modes, programmatic control via
/// [MyTimerController], pluggable formatting, custom builders, and automatic
/// resync after the app returns from the background.
///
/// ```dart
/// MyTimer(
///   duration: const Duration(minutes: 5),
///   direction: TimerDirection.countDown,
///   format: TimerFormat.minutesSeconds,
///   onComplete: () => debugPrint('done'),
/// )
/// ```
class MyTimer extends StatefulWidget {
  const MyTimer({
    super.key,
    this.duration,
    this.tickInterval = const Duration(seconds: 1),
    this.direction = TimerDirection.countUp,
    this.autoStart = true,
    this.controller,
    this.builder,
    this.legacyBuilder,
    this.child,
    this.style,
    this.format = TimerFormat.auto,
    this.formatter,
    this.resyncOnResume = true,
    this.onComplete,
    this.onTick,
    @Deprecated('Use direction: TimerDirection.countUp / countDown')
    this.isIncrementing,
    @Deprecated('Use duration: Duration(...)')
    this.startTimerInSeconds,
    @Deprecated('Use duration: Duration(...)')
    this.endTimerInSeconds,
    @Deprecated('Use tickInterval: Duration(...)')
    this.tickInSecond,
  });

  /// Total duration the timer runs for. Required unless you supply the
  /// legacy [startTimerInSeconds] / [endTimerInSeconds] pair.
  final Duration? duration;

  /// How often the UI is refreshed. The underlying clock is always accurate;
  /// this only controls the rebuild cadence.
  final Duration tickInterval;

  /// Whether the timer counts up from zero or down from [duration].
  final TimerDirection direction;

  /// Whether the timer starts ticking as soon as the widget is mounted.
  /// Set `false` to stay paused until you call `controller.start()`.
  final bool autoStart;

  /// Optional remote control. Lets you start, pause, resume, reset, seek,
  /// and inspect state from outside the widget.
  final MyTimerController? controller;

  /// Renders the timer with full access to elapsed and remaining time.
  /// Takes precedence over [legacyBuilder], [child], [formatter], and [format].
  final MyTimerWidgetBuilder? builder;

  /// 1.x-style builder that exposes only `int remainingTime`.
  /// Kept for backwards compatibility; prefer [builder] in new code.
  final MyTimerLegacyBuilder? legacyBuilder;

  /// Static widget to render in place of the default text.
  final Widget? child;

  /// Text style for the default rendering. Ignored when [builder] or
  /// [legacyBuilder] is set.
  final TextStyle? style;

  /// Built-in format preset. Ignored when [formatter] is set.
  final TimerFormat format;

  /// Custom formatter. Receives the value being displayed (remaining for
  /// count-down, elapsed for count-up).
  final String Function(Duration)? formatter;

  /// Whether to recompute elapsed time when the app returns from background.
  /// Defaults to true. The underlying clock is always accurate; this only
  /// forces an immediate UI refresh after the OS resumes the periodic ticker.
  final bool resyncOnResume;

  /// Fires once when the timer reaches its configured duration.
  /// Convenience that mirrors `controller.onComplete`.
  final VoidCallback? onComplete;

  /// Fires on every UI tick with the current remaining time.
  /// Convenience that mirrors `controller.onTick`.
  final void Function(Duration remaining)? onTick;

  /// **Deprecated.** Use [direction] instead.
  final bool? isIncrementing;

  /// **Deprecated.** Use [duration] instead.
  final int? startTimerInSeconds;

  /// **Deprecated.** Use [duration] instead.
  final int? endTimerInSeconds;

  /// **Deprecated.** Use [tickInterval] instead. Note that 1.x treated this
  /// as a "step size" — that behavior was broken; the new API treats it
  /// purely as a UI refresh cadence.
  final Duration? tickInSecond;

  @override
  State<MyTimer> createState() => _MyTimerState();
}

class _MyTimerState extends State<MyTimer> with WidgetsBindingObserver {
  late MyTimerEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = _buildEngine();
    widget.controller?.attachEngine(_engine);
    if (widget.autoStart) _engine.start();
    if (widget.resyncOnResume) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void didUpdateWidget(covariant MyTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final configChanged = oldWidget.duration != widget.duration ||
        oldWidget.tickInterval != widget.tickInterval ||
        oldWidget.direction != widget.direction ||
        oldWidget.isIncrementing != widget.isIncrementing ||
        oldWidget.startTimerInSeconds != widget.startTimerInSeconds ||
        oldWidget.endTimerInSeconds != widget.endTimerInSeconds ||
        oldWidget.tickInSecond != widget.tickInSecond;

    if (configChanged) {
      oldWidget.controller?.detachEngine();
      _engine.dispose();
      _engine = _buildEngine();
      widget.controller?.attachEngine(_engine);
      if (widget.autoStart) _engine.start();
    } else if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detachEngine();
      widget.controller?.attachEngine(_engine);
    }
  }

  MyTimerEngine _buildEngine() {
    final direction = widget.isIncrementing == null
        ? widget.direction
        : (widget.isIncrementing! ? TimerDirection.countUp : TimerDirection.countDown);

    final tickInterval = widget.tickInSecond ?? widget.tickInterval;

    Duration duration;
    if (widget.duration != null) {
      duration = widget.duration!;
    } else if (widget.startTimerInSeconds != null || widget.endTimerInSeconds != null) {
      final start = widget.startTimerInSeconds ?? 0;
      final end = widget.endTimerInSeconds ?? 120;
      duration = Duration(seconds: (end - start).abs());
    } else {
      duration = const Duration(seconds: 120);
    }

    return MyTimerEngine(
      duration: duration,
      tickInterval: tickInterval,
      direction: direction,
      onTick: (remaining) {
        widget.onTick?.call(remaining);
        widget.controller?.onTick?.call(remaining);
      },
      onComplete: () {
        widget.onComplete?.call();
        widget.controller?.onComplete?.call();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _engine.resyncNow();
    }
  }

  @override
  void dispose() {
    widget.controller?.detachEngine();
    _engine.dispose();
    if (widget.resyncOnResume) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: _engine.elapsed,
      builder: (ctx, elapsed, _) {
        final remaining = _engine.remaining;
        final display = _engine.direction == TimerDirection.countDown ? remaining : elapsed;

        if (widget.builder != null) {
          return widget.builder!(ctx, remaining, elapsed);
        }
        if (widget.legacyBuilder != null) {
          return widget.legacyBuilder!(
            context: ctx,
            remainingTime: display.inSeconds,
          );
        }
        if (widget.child != null) return widget.child!;

        final text = widget.formatter != null
            ? widget.formatter!(display)
            : formatDuration(display, widget.format);

        return Text(
          text,
          style: widget.style ??
              const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
        );
      },
    );
  }
}
