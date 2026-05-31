import 'package:flutter/foundation.dart';

import '../src/my_timer_engine.dart';
import '../src/timer_direction.dart';

/// Programmatic remote control for a [MyTimer] widget.
///
/// Pass an instance to `MyTimer(controller: ...)` and then drive the timer
/// from anywhere in your app:
///
/// ```dart
/// final c = MyTimerController(onComplete: () => print('done!'));
/// MyTimer(controller: c, duration: const Duration(minutes: 5));
/// // later...
/// c.pause();
/// c.resume();
/// c.add(const Duration(seconds: 30));
/// ```
class MyTimerController {
  MyTimerController({this.onTick, this.onComplete});

  /// Fires on every UI tick with the current remaining time.
  void Function(Duration remaining)? onTick;

  /// Fires once when the timer reaches its configured duration.
  VoidCallback? onComplete;

  MyTimerEngine? _engine;

  /// Whether this controller is currently attached to a live [MyTimer] widget.
  /// Method calls are safe no-ops when not attached, so it is rarely needed.
  bool get isAttached => _engine != null;

  /// Whether the underlying timer is currently ticking.
  bool get isRunning => _engine?.isRunning ?? false;

  /// Whether the underlying timer has been started, is not running, and has
  /// not yet completed.
  bool get isPaused => _engine?.isPaused ?? false;

  /// Whether the underlying timer has reached its configured duration.
  bool get isCompleted => _engine?.isCompleted ?? false;

  /// Time elapsed since the timer was first started (after seeks/resets).
  Duration get elapsed => _engine?.elapsed.value ?? Duration.zero;

  /// Time remaining until the timer completes.
  Duration get remaining => _engine?.remaining ?? Duration.zero;

  /// Starts (or resumes) the timer.
  void start() => _engine?.start();

  /// Pauses the timer while preserving elapsed time. Alias for [pause].
  /// Kept for backwards compatibility with 1.x — prefer [pause].
  void stop() => _engine?.stop();

  /// Pauses the timer while preserving elapsed time.
  void pause() => _engine?.pause();

  /// Resumes the timer from where it was paused.
  void resume() => _engine?.resume();

  /// Resets elapsed time to zero. Does not auto-start.
  void reset() => _engine?.reset();

  /// Jumps to [position] within the timer's duration. Preserves running state.
  void seek(Duration position) => _engine?.seek(position);

  /// Adds [delta] to the elapsed time.
  void add(Duration delta) => _engine?.add(delta);

  /// Subtracts [delta] from the elapsed time.
  void subtract(Duration delta) => _engine?.subtract(delta);

  /// Returns the value currently being displayed:
  /// remaining time for count-down mode, elapsed time for count-up mode.
  ///
  /// Kept for backwards compatibility with 1.x. Prefer [remaining] or [elapsed].
  Duration getTimer() {
    final e = _engine;
    if (e == null) return Duration.zero;
    return e.direction == TimerDirection.countDown ? e.remaining : e.elapsed.value;
  }

  // --- Internal attachment API used by MyTimer. Do not call from app code. ---

  void attachEngine(MyTimerEngine engine) {
    _engine = engine;
  }

  void detachEngine() {
    _engine = null;
  }
}
