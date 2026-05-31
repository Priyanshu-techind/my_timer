import 'dart:async';

import 'package:flutter/foundation.dart';

import 'timer_direction.dart';

/// Internal engine that powers a [MyTimer].
///
/// Elapsed time is primarily driven by the periodic ticker, but on every
/// tick (and on explicit [resyncNow] calls) it is reconciled against
/// `DateTime.now()` so the timer catches up correctly after the OS throttles
/// or suspends the ticker — e.g. when the app is backgrounded. The
/// [elapsed] notifier is the single source of truth for any UI built on
/// top of the engine.
class MyTimerEngine {
  MyTimerEngine({
    required this.duration,
    required this.tickInterval,
    required this.direction,
    this.onTick,
    this.onComplete,
  });

  /// Total duration the engine will run for.
  final Duration duration;

  /// How often the [elapsed] notifier is updated for the UI.
  final Duration tickInterval;

  /// Direction the engine is reporting in.
  final TimerDirection direction;

  /// Called on every UI tick with the current [remaining] value.
  final void Function(Duration remaining)? onTick;

  /// Called exactly once when [elapsed] reaches [duration].
  final VoidCallback? onComplete;

  /// Current elapsed time. Updated on every tick.
  final ValueNotifier<Duration> elapsed = ValueNotifier(Duration.zero);

  Duration _elapsed = Duration.zero;
  Duration _elapsedAtSegmentStart = Duration.zero;
  DateTime? _segmentStartedAt;
  Timer? _ticker;
  bool _completed = false;
  bool _disposed = false;

  /// Current elapsed time, clamped to `[Duration.zero, duration]`.
  Duration get currentElapsed {
    if (_elapsed >= duration) return duration;
    if (_elapsed < Duration.zero) return Duration.zero;
    return _elapsed;
  }

  /// Remaining time before completion.
  Duration get remaining {
    final r = duration - currentElapsed;
    return r < Duration.zero ? Duration.zero : r;
  }

  /// Whether the engine is currently ticking.
  bool get isRunning => _ticker != null;

  /// True if the engine has been started, is not running, and has not yet
  /// completed.
  bool get isPaused =>
      _ticker == null && currentElapsed > Duration.zero && !_completed;

  /// True once the engine has reached [duration].
  bool get isCompleted => _completed;

  /// Starts (or resumes) the engine. No-op if already running or completed.
  void start() {
    if (_disposed || _completed || _ticker != null) return;
    _elapsedAtSegmentStart = _elapsed;
    _segmentStartedAt = DateTime.now();
    _ensureTicker();
    _emit();
  }

  /// Pauses the engine while preserving elapsed time. Resume with [start].
  void pause() {
    if (_disposed || _ticker == null) return;
    _syncFromWallClock();
    _cancelTicker();
    _segmentStartedAt = null;
    _emit();
  }

  /// Alias for [start] — provided for API readability.
  void resume() => start();

  /// Pauses the engine. Historically named `stop` in 1.x; preserved for
  /// backwards compatibility.
  void stop() => pause();

  /// Stops the engine and resets elapsed time to zero.
  void reset() {
    if (_disposed) return;
    _cancelTicker();
    _elapsed = Duration.zero;
    _elapsedAtSegmentStart = Duration.zero;
    _segmentStartedAt = null;
    _completed = false;
    _emit();
  }

  /// Jumps to [position] within the engine's duration. Preserves running state.
  void seek(Duration position) {
    if (_disposed) return;
    final wasRunning = _ticker != null;
    _cancelTicker();
    var p = position;
    if (p < Duration.zero) p = Duration.zero;
    if (p > duration) p = duration;
    _elapsed = p;
    _elapsedAtSegmentStart = p;
    _completed = p >= duration;
    if (wasRunning && !_completed) {
      _segmentStartedAt = DateTime.now();
      _ensureTicker();
    } else {
      _segmentStartedAt = null;
    }
    _emit();
  }

  /// Adds [delta] to the current elapsed time.
  void add(Duration delta) => seek(currentElapsed + delta);

  /// Subtracts [delta] from the current elapsed time.
  void subtract(Duration delta) => seek(currentElapsed - delta);

  /// Forces an immediate reconcile against `DateTime.now()` and rebuilds.
  /// Called by the widget on `AppLifecycleState.resumed` so countdowns
  /// stay correct after the OS throttled the periodic ticker.
  void resyncNow() {
    _syncFromWallClock();
    _emit();
  }

  void _syncFromWallClock() {
    final start = _segmentStartedAt;
    if (start == null) return;
    final wallElapsed = DateTime.now().difference(start);
    final candidate = _elapsedAtSegmentStart + wallElapsed;
    if (candidate > _elapsed) _elapsed = candidate;
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(tickInterval, (_) {
      _elapsed += tickInterval;
      _syncFromWallClock();
      _emit();
    });
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _emit() {
    if (_disposed) return;
    final clamped = currentElapsed;
    elapsed.value = clamped;
    onTick?.call(remaining);
    if (!_completed && clamped >= duration) {
      _completed = true;
      _cancelTicker();
      _segmentStartedAt = null;
      _elapsed = duration;
      elapsed.value = duration;
      onComplete?.call();
    }
  }

  /// Releases resources. The engine cannot be used afterwards.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _cancelTicker();
    elapsed.dispose();
  }
}
